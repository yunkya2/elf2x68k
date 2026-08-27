#!/usr/bin/env python3
import argparse
import csv
import re
from pathlib import Path

MAX_ARGS = 6
ABI_GCC = "gcc"
ABI_XC = "xc"

COL_IOCS_NUMBER = 0
COL_API_NAME = 1
COL_RETURN_TYPE = 2
COL_ARG1_REGISTER = 3
COL_ARG_STRIDE = 3
COL_DESCRIPTION = 21
CONTROL_PREFIXES = "#%"

REG_SPEC_PATTERN = re.compile(r"^([da][0-7])(hb|h|l|b)?$")
RETURN_REG_PATTERN = re.compile(r"^[da][0-7]$", re.IGNORECASE)
ABI_CALLEE_SAVED = {
    ABI_XC: ["d3", "d4", "d5", "d6", "d7", "a3", "a4", "a5", "a6"],
    ABI_GCC: ["d2", "d3", "d4", "d5", "d6", "d7", "a2", "a3", "a4", "a5", "a6"],
}


def ident_from_call_name(name: str) -> str:
    """IOCSコール名を検証し、先頭のアンダースコアを除いた識別子を返す。"""
    if re.match(r"^_[A-Za-z0-9_]+$", name):
        return name[1:].lower()
    return ""


def split_call_name_controls(name: str):
    """API名の先頭に付いた制御文字群と実際のAPI名を分離する。"""
    flags = set()
    i = 0
    while i < len(name) and name[i] in CONTROL_PREFIXES:
        flags.add(name[i])
        i += 1
    return flags, name[i:]


def is_comment_row_number(number: str) -> bool:
    """コール番号欄がコメント行を表しているか判定する。"""
    return (number or "").strip().startswith("#")


def is_no_define_api_name(name: str) -> bool:
    """APIがコール番号マクロの生成対象外か判定する。"""
    flags, _ = split_call_name_controls(name)
    return "#" in flags


def is_const_define_api_name(name: str) -> bool:
    """APIが引数定数を値とするマクロ定義か判定する。"""
    flags, _ = split_call_name_controls(name)
    return "%" in flags


def normalized_call_name(name: str) -> str:
    """API名から生成制御用の接頭辞を取り除く。"""
    _, base_name = split_call_name_controls(name)
    return base_name


def c_func_name_from_call_name(name: str) -> str:
    """API名から公開C関数名を生成する。"""
    ident = ident_from_call_name(normalized_call_name(name))
    if not ident:
        return ""
    return f"_iocs_{ident}"


def macro_name_from_call_name(name: str) -> str:
    """API名からIOCSコール番号マクロ名を生成する。"""
    ident = ident_from_call_name(normalized_call_name(name))
    if not ident:
        return ""
    return f"_{ident.upper()}"


def call_literal(number_text: str) -> str:
    """IOCSコール番号をtrap命令用の符号付き即値へ変換する。"""
    num = int(number_text, 0)
    if num < 0x80:
        return num
    else:
        return -(256 - num)


def load_csv_rows(csv_path: Path):
    """IOCSコール定義CSVを読み込み、空行を除いた行一覧を返す。"""
    with csv_path.open("r", encoding="utf-8-sig", newline="") as f:
        rows = []
        for row in csv.reader(f):
            if not row:
                continue
            rows.append(row)
    return rows


def parse_override_sections(text: str):
    """overrideファイルをlibセクションとinlineセクションに分割する。"""
    sections = {}
    current = None
    buffer = []
    for line in text.splitlines():
        match = re.match(r"^\[(lib|inline)\]\s*$", line.strip(), re.IGNORECASE)
        if match:
            if current is not None:
                sections[current] = "\n".join(buffer)
            current = match.group(1).lower()
            buffer = []
            continue
        if current is not None:
            buffer.append(line)
    if current is not None:
        sections[current] = "\n".join(buffer)
    return sections


def filter_override_abi_lines(text: str, abi: str) -> str:
    """override本文のABI指定行から対象ABIの内容だけを抽出する。"""
    if not re.search(r"^@(xc|gcc)(?:[ \t]|$)", text, re.MULTILINE):
        return text
    lines = []
    for line in text.splitlines():
        match = re.match(r"^@(xc|gcc)(?:[ \t](.*))?$", line)
        if match:
            if match.group(1) == abi:
                lines.append(match.group(2) or "")
            continue
        lines.append(line)
    return "\n".join(lines)


def load_override_index(override_dir: Path):
    """overrideディレクトリを走査し、名前とコール番号から引ける索引を作る。"""
    index = {"aliases": {}, "files": []}
    if override_dir is None or not override_dir.exists() or not override_dir.is_dir():
        return index

    # 検索結果を再現可能にするため、ファイル名順に読み込む。
    for path in sorted(override_dir.iterdir()):
        if not path.is_file():
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        sections = parse_override_sections(content)
        if not sections:
            continue
        stem_lower = path.stem.lower()
        # ファイル名中の IOCS コール番号を取得する（例: iocsad_b_scroll → ad）。
        hex_match = re.search(r"iocs([0-9a-fA-F]{2})", stem_lower)
        hex_part = hex_match.group(1).lower() if hex_match else None
        index["files"].append(
            {
                "stem_lower": stem_lower,
                "hex_part": hex_part,
                "sections": sections,
            }
        )
        aliases = {
            path.name,
            path.name.lower(),
            path.stem,
            path.stem.lower(),
        }
        for alias in aliases:
            if alias not in index["aliases"]:
                index["aliases"][alias] = sections
    return index


def override_lookup_keys(call_name: str, call_number: str = ""):
    """APIに対応するoverrideを検索するための候補キーを優先順に返す。"""
    base = normalized_call_name(call_name)
    token = normalize_filename_token(base, base)
    ident = ident_from_call_name(base)

    keys = []

    # コール番号を含む、より限定的なキーを優先する。
    if call_number:
        try:
            hex_num = int(call_number, 0)
            hex_str = f"{hex_num:02x}"
            keys.append(f"iocs{hex_str}")
            if token:
                keys.append(f"iocs{hex_str}_{token}")
            if ident:
                keys.append(f"iocs{hex_str}_{ident}")
        except ValueError:
            pass

    # 番号で見つからない場合に備え、API 名だけのキーも登録する。
    keys.extend([base, token, base.lower(), token.lower()])
    if ident:
        keys += [ident, ident.lower(), ident.upper()]

    seen = set()
    out = []
    for key in keys:
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(key)
    return out


def resolve_override_sections(override_index, call_name: str, call_number: str = ""):
    """索引からAPI名とコール番号に対応するoverrideセクションを検索する。"""
    if not override_index:
        return None
    aliases = override_index.get("aliases", {})
    files = override_index.get("files", [])

    # ファイル名に埋め込まれた番号との照合用に 16 進文字列へ変換する。
    call_hex = None
    if call_number:
        try:
            hex_num = int(call_number, 0)
            call_hex = f"{hex_num:02x}".lower()
        except ValueError:
            pass
    
    for key in override_lookup_keys(call_name, call_number):
        sections = aliases.get(key)
        if sections is not None:
            return sections
        key_lower = key.lower()
        sections = aliases.get(key_lower)
        if sections is not None:
            return sections
        for entry in files:
            stem_lower = entry["stem_lower"]
            file_hex = entry.get("hex_part")

            # ファイル名に番号がある場合は、対象のコール番号との完全一致を必須とする。
            if file_hex is not None and call_hex is not None and file_hex != call_hex:
                continue

            if stem_lower == key_lower or stem_lower.endswith("_" + key_lower):
                return entry["sections"]
    return None


def normalize_identifier(name: str) -> str:
    """文字列を有効なC識別子へ正規化する。"""
    text = re.sub(r"\s+", "_", name.strip())
    text = re.sub(r"[^A-Za-z0-9_]", "_", text)
    if re.match(r"^[0-9]", text):
        text = "_" + text
    return text


def normalize_filename_token(text: str, fallback: str) -> str:
    """文字列を生成ファイル名に使用可能なトークンへ正規化する。"""
    token = re.sub(r"[^A-Za-z0-9_]+", "_", (text or "").strip())
    token = token.strip("_")
    return token or fallback


def cell(row, idx: int) -> str:
    """CSV行から指定列を安全に取得し、前後の空白を除去する。"""
    if idx < 0 or idx >= len(row):
        return ""
    return (row[idx] or "").strip()


def first_const_arg_text(row):
    """CSV行で最初に見つかった定数引数の文字列表現を返す。"""
    for index in range(1, MAX_ARGS + 1):
        base = COL_ARG1_REGISTER + (index - 1) * COL_ARG_STRIDE
        type_cell = cell(row, base + 1)
        if not type_cell:
            continue
        try:
            int(type_cell, 0)
        except ValueError:
            continue
        return type_cell
    return ""


def is_define_only_row(row) -> bool:
    """CSV行が番号マクロだけを生成する行か判定する。"""
    return cell(row, COL_RETURN_TYPE) == ""


def parse_return_type(ret_text: str):
    """戻り値欄をC型、noreturn/const指定、戻り値レジスタに分解する。"""
    text = (ret_text or "").strip()
    is_noreturn = False
    is_const = False
    while text and text[0] in "!%":
        if text[0] == "!":
            is_noreturn = True
        elif text[0] == "%":
            is_const = True
        text = text[1:].strip()
    return_type = text
    return_reg = "d0"
    if "=" in text:
        return_type, return_reg = (part.strip() for part in text.rsplit("=", 1))
        if "=" in return_type or not RETURN_REG_PATTERN.fullmatch(return_reg):
            raise ValueError(f"不正な戻り値レジスタです: {ret_text}")
        return_reg = return_reg.lower()
    return_type = return_type or "int"
    return return_type, is_noreturn, is_const, return_reg


def function_attribute(is_noreturn: bool, is_const: bool) -> str:
    """関数宣言へ付加するGNU属性を返す。"""
    attrs = []
    if is_noreturn:
        attrs.append("noreturn")
    if is_const:
        attrs.append("const")
    return f"__attribute__(({', '.join(attrs)}))" if attrs else ""


def parse_reg_value(reg_text: str) -> str:
    """レジスタ指定を正規化し、IOCS引数として有効か検証する。"""
    reg = (reg_text or "").strip().lower()
    if not reg:
        return ""
    match = REG_SPEC_PATTERN.match(reg)
    if not match:
        raise ValueError(f"不正なレジスタ名です: {reg_text}")
    base, part = match.groups()
    if part and base.startswith("a"):
        raise ValueError(f"アドレスレジスタに h/l は使えません: {reg_text}")
    return reg


def split_reg_spec(reg: str):
    """レジスタ指定を基本レジスタ名と部分指定に分解する。"""
    match = REG_SPEC_PATTERN.match(reg)
    if not match:
        raise ValueError(f"不正なレジスタ名です: {reg}")
    return match.groups()


def parse_param_fields(type_cell: str, name_cell: str, reg: str, is_output: bool):
    """引数の型・名前・レジスタ欄をコード生成用の引数情報へ変換する。"""
    ctype = (type_cell or "").strip()
    name_raw = (name_cell or "").strip()
    try:
        const_value = int(ctype, 0)
    except ValueError:
        const_value = None
    if is_output:
        if not ctype or not name_raw:
            raise ValueError(f"出力引数にはC型と名前が必要です: {reg}")
        if const_value is not None or "*" not in ctype:
            raise ValueError(f"出力引数にはポインタ型が必要です: {type_cell}")
        return {
            "reg": reg,
            "kind": "out",
            "ctype": ctype,
            "name": normalize_identifier(name_raw),
        }
    if const_value is not None:
        return {"reg": reg, "kind": "const", "value": const_value}
    if not ctype or not name_raw:
        raise ValueError(f"通常引数にはC型と名前が必要です: {reg}")
    return {
        "reg": reg,
        "kind": "arg",
        "ctype": ctype,
        "name": normalize_identifier(name_raw),
    }


def build_param_list(row):
    """CSV行の引数欄を解析し、関数の引数情報一覧を構築する。"""
    params = []
    # 各引数は「レジスタ・C型または定数・名前」の3列で構成される。
    for index in range(1, MAX_ARGS + 1):
        base = COL_ARG1_REGISTER + (index - 1) * COL_ARG_STRIDE
        reg_cell = cell(row, base)
        type_cell = cell(row, base + 1)
        name_cell = cell(row, base + 2)
        if not ((reg_cell or "").strip() or (type_cell or "").strip() or (name_cell or "").strip()):
            break
        is_output = reg_cell.startswith("=")
        reg_text = reg_cell[1:].strip() if is_output else reg_cell
        reg = parse_reg_value(reg_text)
        if not reg:
            raise ValueError(f"Arg{index} register is empty")
        parsed = parse_param_fields(type_cell, name_cell, reg, is_output)
        params.append(parsed)
    return params


def format_param_decl(ctype: str, name: str) -> str:
    """C型と引数名を宣言へ整形し、型中の%を引数名の挿入位置として置換する。"""
    t = (ctype or "").strip()
    if "%" in t:
        return t.replace("%", name)
    if re.search(r"[A-Za-z0-9_]$", t):
        return f"{t} {name}"
    return f"{t}{name}"


def param_proto(params) -> str:
    """引数情報からC関数の仮引数リストを生成する。"""
    args = [
        format_param_decl(param["ctype"], param["name"])
        for param in params
        if param["kind"] in ("arg", "out")
    ]
    return ", ".join(args) or "void"


def param_label(param) -> str:
    """生成ヘッダーの説明用にレジスタと引数の対応を文字列化する。"""
    if param["kind"] == "const":
        return f"{param['reg']}=#{param['value']}"
    if param["kind"] == "out":
        return f"={param['reg']}->{param['name']}"
    return f"{param['reg']}={param['name']}"


def build_reg_map(params):
    """引数を基本レジスタごとに整理し、重複する割り当てを検出する。"""
    reg_order = []
    reg_map = {}
    # fullと部分指定を同じ基本レジスタ配下へ集約する。
    for param in params:
        if param["kind"] == "out":
            continue
        reg = param["reg"]
        base, part = split_reg_spec(reg)
        if base not in reg_map:
            reg_map[base] = {"full": None, "h": None, "l": None, "hb": None, "b": None}
            reg_order.append(base)
        if part is None:
            # 全体指定と部分指定は同じレジスタに共存できない。
            if (
                reg_map[base]["full"] is not None
                or reg_map[base]["h"] is not None
                or reg_map[base]["l"] is not None
                or reg_map[base]["hb"] is not None
                or reg_map[base]["b"] is not None
            ):
                raise ValueError(f"同じレジスタへの重複指定です: {base}")
            reg_map[base]["full"] = param
        else:
            if reg_map[base]["full"] is not None:
                raise ValueError(f"同じレジスタへの重複指定です: {base}")
            if reg_map[base][part] is not None:
                raise ValueError(f"同じレジスタ上位/下位の重複指定です: {reg}")
            reg_map[base][part] = param
    return reg_order, reg_map


def render_inline_reg_value(base: str, param) -> str:
    """固定レジスタ変数の初期値となるC式を生成する。"""
    if param["kind"] == "const":
        if base.startswith("d"):
            return str(param["value"])
        return f"(void *){param['value']}"
    if base.startswith("d"):
        return f"(int){param['name']}"
    return f"(void *){param['name']}"


def render_split_inline_value(param) -> str:
    """レジスタ部分指定へ格納する値のC式を生成する。"""
    if param["kind"] == "const":
        return str(param["value"])
    return param["name"]


def emit_split_source_movew(lines, base: str, param, saved_bytes: int):
    """ワード部分指定をレジスタへロードするアセンブリ命令を追加する。"""
    if param["kind"] == "const":
        lines.append(f"\tmovew\t#{param['value']}, %{base}")
    else:
        lines.append(f"\tmovew\t%sp@({param['stack_offset'] + 2 + saved_bytes}), %{base}")


def emit_split_source_moveb(lines, base: str, param, saved_bytes: int):
    """バイト部分指定をレジスタへロードするアセンブリ命令を追加する。"""
    if param["kind"] == "const":
        lines.append(f"\tmoveb\t#{param['value'] & 0xff}, %{base}")
    else:
        lines.append(f"\tmoveb\t%sp@({param['stack_offset'] + 3 + saved_bytes}), %{base}")


def emit_data_const_load(lines, reg: str, value: int):
    """定数値に応じて最短のデータレジスタロード命令を追加する。"""
    if -128 <= value <= 127:
        lines.append(f"\tmoveq\t#{value}, %{reg}")
    else:
        lines.append(f"\tmovel\t#{value}, %{reg}")


def reglist_operand(regs):
    """レジスタ一覧をmovem命令のオペランド表記へ変換する。"""
    return "/".join(f"%{reg}" for reg in regs)


def callee_saved_to_preserve(abi: str, clobbered_regs):
    """破壊対象のうち指定ABIで保存が必要なレジスタを返す。"""
    return [reg for reg in ABI_CALLEE_SAVED[abi] if reg in clobbered_regs]


def output_address_regs_for_abi(abi: str, output_regs):
    """出力ポインタのロードに利用できるアドレスレジスタを優先順に返す。"""
    address_regs = [f"a{index}" for index in range(7)]
    caller_saved = [
        reg
        for reg in address_regs
        if reg not in ABI_CALLEE_SAVED[abi] and reg not in output_regs
    ]
    if caller_saved:
        return caller_saved

    # 結果値がcaller-savedアドレスレジスタをすべて占有する場合だけ、
    # 未使用のcallee-savedレジスタを1本退避して作業領域にする。
    return [next(reg for reg in address_regs if reg not in output_regs)]


def group_output_params(output_params, max_count: int):
    """スタック上で連続する出力ポインタをmovem可能な大きさに分割する。"""
    groups = []
    index = 0
    while index < len(output_params):
        group = [output_params[index]]
        while (
            len(group) < max_count
            and index + len(group) < len(output_params)
            and output_params[index + len(group)]["stack_offset"]
            == group[-1]["stack_offset"] + 4
        ):
            group.append(output_params[index + len(group)])
        groups.append(group)
        index += len(group)
    return groups


def reg_order_key(reg: str):
    """レジスタをmovem命令の並び順で比較するためのキーを返す。"""
    kind = 0 if reg.startswith("d") else 1
    return (kind, int(reg[1:]))


def exg_permutation(loaded_regs, desired_regs):
    """movemでロードした値を目的の配置へ直す最小のexg手順を求める。"""
    value_in_reg = dict(zip(loaded_regs, desired_regs))
    exchanges = []
    # 各目的レジスタを順番に確定させれば、閉路ごとに最小回数で交換できる。
    for target in desired_regs:
        if value_in_reg[target] == target:
            continue
        source = next(reg for reg, value in value_in_reg.items() if value == target)
        exchanges.append((target, source))
        value_in_reg[target], value_in_reg[source] = (
            value_in_reg[source],
            value_in_reg[target],
        )
    return exchanges


def emit_exg_permutation(lines, exchanges):
    """レジスタ交換手順をexg命令として出力行へ追加する。"""
    for left, right in exchanges:
        # GNU as が受理する混在形式 exg Dn,An に並べる。
        if left.startswith("a") and right.startswith("d"):
            left, right = right, left
        lines.append(f"\texg\t%{left}, %{right}")


def is_deferred_const_d1(base: str, spec) -> bool:
    """trap番号設定後までロードを遅延すべきd1定数引数か判定する。"""
    return base == "d1" and spec["full"] is not None and spec["full"]["kind"] == "const"


def emit_inline_header(rows, out_path: Path, override_index=None):
    """全IOCSコールのインライン関数ヘッダーを生成する。"""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "#ifndef _IOCS_INLINE_H_",
        "#define _IOCS_INLINE_H_",
        "/* automatically generated from iocscall.csv */",
        "",
        "#ifndef __IOCS_INLINE__",
        "#define __IOCS_INLINE__",
        "#endif",
        "#include <x68k/iocs.h>",
        "",
        "__BEGIN_DECLS",
        "",
    ]
    # CSVの各有効行を、固定レジスタ変数を使うstatic inline関数へ変換する。
    for row in rows:
        number = cell(row, COL_IOCS_NUMBER)
        if not number:
            lines.append("/*----*/")
            lines.append("")
            continue
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_API_NAME)
        if not call_name:
            continue
        if is_define_only_row(row):
            continue
        emitted_call_name = normalized_call_name(call_name)
        literal = call_literal(number)
        ident = ident_from_call_name(emitted_call_name)
        if not ident:
            continue
        sections = resolve_override_sections(override_index, call_name, number)
        inline_text = sections.get("inline") if sections else None
        if inline_text is not None:
            # 個別実装があるAPIは自動生成せず、override本文をそのまま採用する。
            if inline_text:
                lines.extend(inline_text.splitlines())
            lines.append("")
            continue
        ret_type, is_noreturn, is_const, return_reg = parse_return_type(
            cell(row, COL_RETURN_TYPE)
        )
        fn = c_func_name_from_call_name(call_name)
        params = build_param_list(row)
        proto = param_proto(params)
        lines.append(f"/* {number} {emitted_call_name}: {cell(row, COL_DESCRIPTION)} */")
        if params:
            labels = ", ".join(param_label(param) for param in params)
            lines.append(f"/* args: {labels} */")

        attr = function_attribute(is_noreturn, is_const)
        if attr:
            lines.append(attr)
        lines.append(f"static __inline__ {ret_type} {fn}({proto}) {{")

        # 引数を基本レジスタ単位にまとめ、全体指定と部分指定を組み立てる。
        reg_order, reg_map = build_reg_map(params)
        output_params = [param for param in params if param["kind"] == "out"]
        result_regs = {param["reg"] for param in output_params}
        if return_reg != "d0":
            result_regs.add(return_reg)
        deferred_const_d1 = reg_map.get("d1") if "d1" in reg_map and is_deferred_const_d1("d1", reg_map["d1"]) else None

        for base in reg_order:
            spec = reg_map[base]
            if deferred_const_d1 is spec:
                continue
            if spec["full"] is not None:
                if base.startswith("d"):
                    lines.append(f"    register int _{base} __asm__(\"{base}\") = {render_inline_reg_value(base, spec['full'])};")
                else:
                    lines.append(f"    register void *_{base} __asm__(\"{base}\") = {render_inline_reg_value(base, spec['full'])};")
                continue

            if base.startswith("a"):
                raise ValueError(f"アドレスレジスタに分割指定はできません: {base}")

            lines.append(f"    register int _{base} __asm__(\"{base}\") = 0;")
            if spec["h"] is not None:
                lines.append(f"    _{base} |= (((int){render_split_inline_value(spec['h'])}) & 0xffff) << 16;")
            if spec["l"] is not None:
                lines.append(f"    _{base} |= ((int){render_split_inline_value(spec['l'])}) & 0xffff;")
            if spec["hb"] is not None:
                lines.append(f"    _{base} |= (((int){render_split_inline_value(spec['hb'])}) & 0xff) << 8;")
            if spec["b"] is not None:
                lines.append(f"    _{base} |= ((int){render_split_inline_value(spec['b'])}) & 0xff;")

        # 入力に含まれない結果レジスタには、出力専用の固定レジスタ変数を用意する。
        for result_reg in sorted(result_regs, key=reg_order_key):
            if result_reg == "d0" or result_reg in reg_map:
                continue
            result_reg_type = "int" if result_reg.startswith("d") else "void *"
            lines.append(
                f"    register {result_reg_type} _{result_reg} "
                f"__asm__(\"{result_reg}\");"
            )

        if deferred_const_d1 is not None:
            lines.append(f"    register int _d1 __asm__(\"d1\") = {render_inline_reg_value('d1', deferred_const_d1['full'])};")
        # d0にコール番号を置き、引数レジスタを入出力オペランドとしてtrapを実行する。
        lines.append(f"    register int _d0 __asm__(\"d0\") = {literal};")
        outputs = ['"+d"(_d0)']
        for base in reg_order:
            outputs.append(f"\"{'+d' if base.startswith('d') else '+a'}\"(_{base})")
        for result_reg in sorted(result_regs, key=reg_order_key):
            if result_reg == "d0" or result_reg in reg_map:
                continue
            constraint = "=d" if result_reg.startswith("d") else "=a"
            outputs.append(f'"{constraint}"(_{result_reg})')

        lines.append(
            "    __asm__ __volatile__ (\"trap #15\" : "
            + ",".join(outputs)
            + " : : \"cc\",\"memory\");"
        )

        # =レジスタ指定の引数へ、trap後の32bitレジスタ値を書き戻す。
        for output_param in output_params:
            lines.append(
                f"    *(int *){output_param['name']} = "
                f"(int)_{output_param['reg']};"
            )

        if is_noreturn:
            lines.append("    __builtin_unreachable();")
        elif ret_type == "void":
            lines.append("    return;")
        else:
            lines.append(f"    return ({ret_type})_{return_reg};")

        lines.append("}")

        lines.append("")
    lines += [
        "__END_DECLS",
        "",
        "#endif /* _IOCS_INLINE_H_ */",
    ]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def emit_proto_header(rows, out_path: Path):
    """ライブラリ関数のプロトタイプ宣言ヘッダーを生成する。"""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "#ifndef _IOCS_PROTO_H_",
        "#define _IOCS_PROTO_H_",
        "/* automatically generated from iocscall.csv */",
        "",
        "#include <x68k/iocs.h>",
        "",
        "__BEGIN_DECLS",
        "",
    ]
    # ヘッダー専用行とdefine専用行を除き、外部関数の宣言を並べる。
    for row in rows:
        number = cell(row, COL_IOCS_NUMBER)
        if not number:
            lines.append("")
            continue
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_API_NAME)
        if not call_name:
            continue
        if is_define_only_row(row):
            continue
        ident = ident_from_call_name(normalized_call_name(call_name))
        if not ident:
            continue
        ret_type, is_noreturn, is_const, _return_reg = parse_return_type(
            cell(row, COL_RETURN_TYPE)
        )
        fn = c_func_name_from_call_name(call_name)
        params = build_param_list(row)
        proto = param_proto(params)
        attr_text = function_attribute(is_noreturn, is_const)
        attr = f" {attr_text}" if attr_text else ""
        lines.append(f"{ret_type} {fn}({proto}){attr};")
    lines += [
        "",
        "__END_DECLS",
        "",
        "#endif /* _IOCS_PROTO_H_ */",
    ]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def emit_call_number_header(rows, out_path: Path):
    """IOCSコール番号または定数引数を定義するマクロヘッダーを生成する。"""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "#ifndef _IOCSCALL_H_",
        "#define _IOCSCALL_H_",
        "/* automatically generated from iocscall.csv */",
        "",
    ]
    # 同名APIが複数行に現れても、番号マクロは最初の1回だけ生成する。
    seen = set()
    for row in rows:
        number = cell(row, COL_IOCS_NUMBER)
        if not number:
            lines.append("")
            continue
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_API_NAME)
        if not call_name:
            continue
        if is_no_define_api_name(call_name):
            continue
        macro = macro_name_from_call_name(call_name)
        if not macro or macro in seen:
            continue
        desc = cell(row, COL_DESCRIPTION)
        if is_const_define_api_name(call_name):
            literal = first_const_arg_text(row)
            if not literal:
                continue
        else:
            literal = number
        if desc:
            lines.append(f"#define {macro:15} {literal}   /* {desc} */")
        else:
            lines.append(f"#define {macro:15} {literal}")
        seen.add(macro)
    lines += ["", "#endif"]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")

def emit_lib_source(
    rows,
    out_dir: Path,
    abi: str,
    two_reg_save_style: str,
    override_index=None,
):
    """各IOCSコールを呼び出すライブラリ用アセンブリソースを生成する。"""
    out_dir.mkdir(parents=True, exist_ok=True)
    # 生成対象行を選別し、APIごとに独立した.Sファイルを書き出す。
    for row in rows:
        number = cell(row, COL_IOCS_NUMBER)
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_API_NAME)
        if not call_name or not number:
            continue
        if is_define_only_row(row):
            continue
        emitted_call_name = normalized_call_name(call_name)
        literal = call_literal(number)
        ident = ident_from_call_name(emitted_call_name)
        if not ident:
            continue

        out_path = out_dir / f"iocs{int(number, 0):02x}_{ident}.S"
        sections = resolve_override_sections(override_index, call_name, number)
        lib_text = sections.get("lib") if sections else None
        if lib_text is not None:
            # ABI固有の個別実装があれば自動生成より優先する。
            lib_text = filter_override_abi_lines(lib_text, abi)
            out_path.write_text(lib_text + "\n", encoding="utf-8", newline="\n")
            continue
        lines = []

        ret_type, is_noreturn, _is_const, return_reg = parse_return_type(
            cell(row, COL_RETURN_TYPE)
        )
        fn = c_func_name_from_call_name(call_name)
        params = build_param_list(row)
        proto = param_proto(params)
        lines.append(f"/* {number} {emitted_call_name}: {cell(row, COL_DESCRIPTION)} */")

        lines.append(f"/* {ret_type} {fn}({proto}); */")

        lines.append("")
        lines.append("\t.text")
        lines.append("\t.even")
        lines.append(f"\t.global {fn}")
        lines.append(f"\t.type {fn}, @function")
        lines.append("")
        lines.append(f"{fn}:")

        # 戻りアドレス直後から始まるC引数のスタック位置を記録する。
        offset = 4
        for param in params:
            if param["kind"] in ("arg", "out"):
                param["stack_offset"] = offset
                offset += 4

        reg_order, reg_map = build_reg_map(params)
        output_params = [param for param in params if param["kind"] == "out"]
        output_regs = {param["reg"] for param in output_params}
        output_address_regs = output_address_regs_for_abi(abi, output_regs)
        output_param_groups = group_output_params(
            output_params, len(output_address_regs)
        )
        deferred_const_d1 = reg_map.get("d1") if "d1" in reg_map and is_deferred_const_d1("d1", reg_map["d1"]) else None
        # APIが使用するcallee-savedレジスタだけを必要最小限退避する。
        clobbered_regs = set(reg_order)
        clobbered_regs.update(output_regs)
        if output_params:
            clobbered_regs.update(
                output_address_regs[: min(len(output_params), len(output_address_regs))]
            )
        if return_reg != "d0":
            clobbered_regs.add(return_reg)
        saved_regs = callee_saved_to_preserve(abi, clobbered_regs)
        if is_noreturn:
            saved_regs = []
        saved_bytes = len(saved_regs) * 4

        if saved_regs:
            if len(saved_regs) == 1:
                lines.append(f"\tmovel\t%{saved_regs[0]}, %sp@-")
            elif len(saved_regs) == 2 and two_reg_save_style == "movel":
                lines.append(f"\tmovel\t%{saved_regs[0]}, %sp@-")
                lines.append(f"\tmovel\t%{saved_regs[1]}, %sp@-")
            else:
                lines.append(f"\tmoveml\t{reglist_operand(saved_regs)}, %sp@-")

        i = 0
        while i < len(reg_order):
            base = reg_order[i]
            spec = reg_map[base]
            if deferred_const_d1 is spec:
                i += 1
                continue

            # 連続するスタック引数について複数のロード列を構築し、
            # 命令サイズが最小になるものを選択する。
            if spec["full"] is not None and spec["full"]["kind"] == "arg":
                run_bases = [base]
                run_offset = spec["full"]["stack_offset"]
                prev_offset = run_offset
                j = i + 1
                while j < len(reg_order):
                    next_base = reg_order[j]
                    next_spec = reg_map[next_base]
                    if deferred_const_d1 is next_spec:
                        break
                    if next_spec["full"] is None or next_spec["full"]["kind"] != "arg":
                        break
                    next_offset = next_spec["full"]["stack_offset"]
                    if next_offset != prev_offset + 4:
                        break
                    run_bases.append(next_base)
                    prev_offset = next_offset
                    j += 1

                # 候補1: 各引数を movel で個別にロードする。
                individual_lines = [
                    f"\tmovel\t%sp@({run_offset + saved_bytes + index * 4}), %{reg}"
                    for index, reg in enumerate(run_bases)
                ]
                best_lines = individual_lines
                best_size = 4 * len(run_bases)

                # 候補2: レジスタ順が昇順の区間を moveml にまとめる。
                # 同サイズなら先に作った候補を維持する。
                ordered_lines = []
                ordered_size = 0
                start = 0
                while start < len(run_bases):
                    end = start + 1
                    while (
                        end < len(run_bases)
                        and reg_order_key(run_bases[end - 1])
                        < reg_order_key(run_bases[end])
                    ):
                        end += 1
                    ordered_run = run_bases[start:end]
                    stack_offset = run_offset + saved_bytes + start * 4
                    if len(ordered_run) >= 2:
                        ordered_lines.append(
                            f"\tmoveml\t%sp@({stack_offset}), {reglist_operand(ordered_run)}"
                        )
                        ordered_size += 6
                    else:
                        ordered_lines.append(
                            f"\tmovel\t%sp@({stack_offset}), %{ordered_run[0]}"
                        )
                        ordered_size += 4
                    start = end
                if ordered_size < best_size:
                    best_lines = ordered_lines
                    best_size = ordered_size

                # 候補3: 先頭のロード先を一時的に d0 とし、全体を moveml で
                # ロードした後、本来の先頭レジスタへ移す。
                tail_bases = run_bases[1:]
                tail_is_ordered = all(
                    reg_order_key(tail_bases[index - 1])
                    < reg_order_key(tail_bases[index])
                    for index in range(1, len(tail_bases))
                )
                if (
                    len(tail_bases) >= 2
                    and tail_is_ordered
                    and "d0" not in run_bases
                ):
                    staged_bases = ["d0", *tail_bases]
                    staged_size = 6 + 2
                    if staged_size < best_size:
                        best_lines = [
                            f"\tmoveml\t%sp@({run_offset + saved_bytes}), {reglist_operand(staged_bases)}",
                            f"\tmovel\t%d0, %{run_bases[0]}",
                        ]
                        best_size = staged_size

                # 候補4: movem のレジスタ順で一括ロードし、最小回数の exg で
                # 本来の割り当てへ並べ替える。
                loaded_bases = sorted(run_bases, key=reg_order_key)
                exchanges = exg_permutation(loaded_bases, run_bases)
                movem_exg_size = 6 + 2 * len(exchanges)
                if len(run_bases) >= 2 and movem_exg_size < best_size:
                    movem_exg_lines = [
                        f"\tmoveml\t%sp@({run_offset + saved_bytes}), {reglist_operand(loaded_bases)}"
                    ]
                    emit_exg_permutation(movem_exg_lines, exchanges)
                    best_lines = movem_exg_lines

                lines.extend(best_lines)
                i = j
                continue

            if spec["full"] is not None:
                param = spec["full"]
                if param["kind"] == "const":
                    if base.startswith("d"):
                        emit_data_const_load(lines, base, param["value"])
                    else:
                        lines.append(f"\tmoveal\t#{param['value']}, %{base}")
                else:
                    lines.append(f"\tmovel\t%sp@({param['stack_offset'] + saved_bytes}), %{base}")
                i += 1
                continue

            if base.startswith("a"):
                raise ValueError(f"アドレスレジスタに分割指定はできません: {base}")

            skip_zero_init = (
                spec["h"] is not None
                and spec["l"] is not None
                and spec["hb"] is None
                and spec["b"] is None
            )
            if not skip_zero_init:
                lines.append(f"\tmoveq\t#0, %{base}")
            if spec["h"] is not None:
                param = spec["h"]
                emit_split_source_movew(lines, base, param, saved_bytes)
                lines.append(f"\tswap\t%{base}")
            if spec["l"] is not None:
                param = spec["l"]
                emit_split_source_movew(lines, base, param, saved_bytes)
            if spec["hb"] is not None:
                param = spec["hb"]
                emit_split_source_moveb(lines, base, param, saved_bytes)
                lines.append(f"\tlslw\t#8, %{base}")
            if spec["b"] is not None:
                param = spec["b"]
                emit_split_source_moveb(lines, base, param, saved_bytes)

            i += 1

        if deferred_const_d1 is not None:
            emit_data_const_load(lines, "d1", deferred_const_d1["full"]["value"])

        lines.append(f"\tmoveq\t#{literal}, %d0")
        lines.append("\ttrap\t#15")
        if not is_noreturn:
            # C ABIの戻り値レジスタはd0なので、指定値を退避レジスタの復帰前に移す。
            if return_reg != "d0":
                lines.append(f"\tmovel\t%{return_reg}, %d0")
            # 連続する出力ポインタを破壊可能なアドレスレジスタへまとめてロードする。
            for output_group in output_param_groups:
                address_regs = output_address_regs[: len(output_group)]
                stack_offset = output_group[0]["stack_offset"] + saved_bytes
                if len(output_group) >= 2:
                    lines.append(
                        f"\tmoveml\t%sp@({stack_offset}), "
                        f"{reglist_operand(address_regs)}"
                    )
                else:
                    lines.append(
                        f"\tmoveal\t%sp@({stack_offset}), %{address_regs[0]}"
                    )
                for output_param, address_reg in zip(output_group, address_regs):
                    lines.append(
                        f"\tmovel\t%{output_param['reg']}, %{address_reg}@"
                    )
            if saved_regs:
                if len(saved_regs) == 1:
                    lines.append(f"\tmovel\t%sp@+, %{saved_regs[0]}")
                elif len(saved_regs) == 2 and two_reg_save_style == "movel":
                    lines.append(f"\tmovel\t%sp@+, %{saved_regs[1]}")
                    lines.append(f"\tmovel\t%sp@+, %{saved_regs[0]}")
                else:
                    lines.append(f"\tmoveml\t%sp@+,{reglist_operand(saved_regs)}")
            lines.append("\trts")

        out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def main():
    """コマンドライン引数を解析し、すべての生成処理を実行する。"""
    parser = argparse.ArgumentParser(
        description="iocscall.csvからinline header/prototype header/library functionを生成する。"
    )
    parser.add_argument("--csv", type=Path, default=Path("iocscall.csv"))
    parser.add_argument("--inline-h", type=Path, default=Path("out/iocs_inline.h"))
    parser.add_argument("--proto-h", type=Path, default=Path("out/iocs_proto.h"))
    parser.add_argument(
        "--def-h",
        type=Path,
        default=Path("out/iocscall.h"),
    )
    parser.add_argument("--out-dir", type=Path, default=Path("build"))
    parser.add_argument(
        "--override-dir",
        type=Path,
        default=Path("overrides"),
    )
    parser.add_argument(
        "--abi",
        choices=[ABI_XC, ABI_GCC],
        default=ABI_XC,
        help=".S 生成時のレジスタ保存規約。xc: d3-d7/a3-a6, gcc: d2-d7/a2-a6",
    )
    parser.add_argument(
        "--two-reg-save-style",
        choices=["movel", "moveml"],
        default="movel",
        help="保存対象レジスタが2個のときの保存/復帰方式。movel: movelを2命令、moveml: movemlを1命令",
    )
    args = parser.parse_args()

    rows = load_csv_rows(args.csv)
    override_index = load_override_index(args.override_dir)
    emit_inline_header(rows, args.inline_h, override_index)
    emit_proto_header(rows, args.proto_h)
    emit_call_number_header(rows, args.def_h)
    emit_lib_source(
        rows,
        args.out_dir,
        args.abi,
        args.two_reg_save_style,
        override_index,
    )


if __name__ == "__main__":
    main()
