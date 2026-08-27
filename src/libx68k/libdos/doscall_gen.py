#!/usr/bin/env python3
import argparse
import csv
import re
from pathlib import Path

MAX_ARGS = 8
ABI_GCC = "gcc"
ABI_XC = "xc"

COL_DOS_CALL_NUMBER = 0
COL_DOS_CALL_NAME = 1
COL_RETURN_TYPE = 2
COL_ARG1_WIDTH = 3
COL_ARG_STRIDE = 3
COL_DESCRIPTION = 27
CONTROL_PREFIXES = "#"

ABI_CALLEE_SAVED = {
    ABI_XC: ["d3", "d4", "d5", "d6", "d7", "a3", "a4", "a5", "a6"],
    ABI_GCC: ["d2", "d3", "d4", "d5", "d6", "d7", "a2", "a3", "a4", "a5", "a6"],
}

ABI_INLINE_EXTRA_CLOBBERS_FOR_ALL_REGS = {
    ABI_GCC: ["a0", "a1"],
    ABI_XC: ["d2", "a2", "a0", "a1"],
}

def callee_saved_regs_for_abi(abi: str) -> str:
    """指定ABIのcallee-savedレジスタをアセンブリのレジスタリストにする。"""
    regs = ABI_CALLEE_SAVED[abi]
    return "/".join(f"%{reg}" for reg in regs)


def callee_saved_stack_bytes_for_abi(abi: str) -> int:
    """指定ABIのcallee-savedレジスタをすべて保存する際のバイト数を返す。"""
    regs = ABI_CALLEE_SAVED[abi]
    return len(regs) * 4


def call_literal(number_text: str) -> str:
    """CSVのDOSコール番号を検証し、小文字の16進リテラルへ正規化する。"""
    text = number_text.strip().lower()
    if not re.fullmatch(r"0x[0-9a-f]+", text):
        raise ValueError(f"不正なDOSコール番号です: {number_text}")
    return text


def call_code_value(number_text: str) -> int:
    """CSVのDOSコール番号を数値として返す。"""
    return int(call_literal(number_text), 0)


def ident_from_call_name(name: str) -> str:
    """DOSコール名を検証し、先頭のアンダースコアを除いた識別子を返す。"""
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


def normalized_call_name(name: str) -> str:
    """API名から生成制御用の接頭辞を取り除く。"""
    _, base_name = split_call_name_controls(name)
    return base_name


def c_func_name_from_call_name(name: str) -> str:
    """API名から公開C関数名を生成する。"""
    ident = ident_from_call_name(normalized_call_name(name))
    if not ident:
        return ""
    return f"_dos_{ident}"


def macro_name_from_call_name(name: str) -> str:
    """API名からDOSコール番号マクロ名を生成する。"""
    ident = ident_from_call_name(normalized_call_name(name))
    if not ident:
        return ""
    return f"_{ident.upper()}"


def is_define_only_row(row) -> bool:
    """CSV行が番号マクロだけを生成する行か判定する。"""
    return cell(row, COL_RETURN_TYPE) == ""


def parse_return_type(ret_text: str):
    """戻り値欄を型、noreturn/const指定、全レジスタ破壊指定に分解する。"""
    text = (ret_text or "").strip()
    is_noreturn = False
    is_const = False
    clobbers_all_regs = False
    while text and text[0] in "!$%":
        if text[0] == "!":
            is_noreturn = True
        elif text[0] == "$":
            clobbers_all_regs = True
        elif text[0] == "%":
            is_const = True
        text = text[1:].strip()
    if not text:
        text = "int"
    return text, is_noreturn, is_const, clobbers_all_regs


def function_attribute(is_noreturn: bool, is_const: bool) -> str:
    """関数宣言へ付加するGNU属性を返す。"""
    attrs = []
    if is_noreturn:
        attrs.append("noreturn")
    if is_const:
        attrs.append("const")
    return f"__attribute__(({', '.join(attrs)}))" if attrs else ""


def normalize_filename_token(text: str, fallback: str) -> str:
    """文字列を生成ファイル名に使用可能なトークンへ正規化する。"""
    token = re.sub(r"[^A-Za-z0-9_]+", "_", (text or "").strip())
    token = token.strip("_")
    return token or fallback


def load_csv_rows(csv_path: Path):
    """DOSコール定義CSVを読み込み、空行を除いた行一覧を返す。"""
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
    """overrideディレクトリを走査し、ファイル名から検索できる索引を作る。"""
    index = {"aliases": {}, "files": []}
    if override_dir is None or not override_dir.exists() or not override_dir.is_dir():
        return index

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
        index["files"].append(
            {
                "stem_lower": path.stem.lower(),
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


def override_lookup_keys(call_name: str):
    """APIに対応するoverrideを検索するための候補キーを優先順に返す。"""
    base = normalized_call_name(call_name)
    token = normalize_filename_token(base, base)
    ident = ident_from_call_name(base)
    keys = [base, token, base.lower(), token.lower()]
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


def resolve_override_sections(override_index, call_name: str):
    """索引からAPIに対応するoverrideセクションを検索する。"""
    if not override_index:
        return None
    aliases = override_index.get("aliases", {})
    files = override_index.get("files", [])
    for key in override_lookup_keys(call_name):
        sections = aliases.get(key)
        if sections is not None:
            return sections
        key_lower = key.lower()
        sections = aliases.get(key_lower)
        if sections is not None:
            return sections
        # 「任意の接頭辞_API名.拡張子」というファイル名も許容する。
        # 例: dosff20_super.S は API 名 super に一致する。
        for entry in files:
            stem_lower = entry["stem_lower"]
            if stem_lower == key_lower or stem_lower.endswith("_" + key_lower):
                return entry["sections"]
    return None


def cell(row, idx: int) -> str:
    """CSV行から指定列を安全に取得し、前後の空白を除去する。"""
    if idx < 0 or idx >= len(row):
        return ""
    return (row[idx] or "").strip()


def parse_width_spec(width_text: str):
    """引数幅指定を幅とORマスクに分解する。"""
    text = (width_text or "").strip().lower()
    if not text:
        return "", None
    if "|" not in text:
        return text, None
    width, mask_text = [part.strip() for part in text.split("|", 1)]
    if not width:
        return "", None
    if not mask_text:
        raise ValueError("OR mask is empty in width spec")
    try:
        mask_value = int(mask_text, 0)
    except ValueError as e:
        raise ValueError(f"invalid OR mask in width spec: {width_text}") from e
    return width, mask_value


def parse_args(row):
    """CSVの3列1組（幅・型・名前）をコード生成用の引数情報へ変換する。"""
    args = []
    # 各引数は「スタック幅・C型・名前」の3列で構成される。
    for i in range(1, MAX_ARGS + 1):
        base = COL_ARG1_WIDTH + (i - 1) * COL_ARG_STRIDE
        w, or_mask = parse_width_spec(cell(row, base))
        t = cell(row, base + 1)
        n = cell(row, base + 2)
        if not w and not t and not n:
            continue
        if w == "c":
            if or_mask is not None:
                raise ValueError("stack width 'c' does not support OR masks")
            try:
                const_value = int(t, 0)
            except ValueError as e:
                raise ValueError(f"invalid 16-bit constant argument: {t!r}") from e
            if not -0x8000 <= const_value <= 0xFFFF:
                raise ValueError(f"16-bit constant argument out of range: {t}")
            args.append({"argw": "c", "value": const_value})
            continue

        if not t:
            t = "int"
        if not n:
            n = f"arg{i}"
        if w not in ("w", "l", "hb", "b"):
            raise ValueError(f"invalid stack width for non-constant argument: {w!r}")
        # ORマスクを指定されたスタック幅の範囲内に収める。
        if or_mask is not None and w in ("hb", "b"):
            raise ValueError("stack width 'hb'/'b' does not support OR masks")
        if or_mask is not None and w == "w":
            or_mask &= 0xFFFF
        elif or_mask is not None and w == "l":
            or_mask &= 0xFFFFFFFF

        entry = {"argw": w, "ctype": t, "name": n}
        if or_mask is not None:
            entry["or_mask"] = or_mask
        args.append(entry)
    return args


def cleanup_asm(total_bytes: int) -> str:
    """DOSコール後に積み直した引数を破棄するスタック復帰命令を生成する。"""
    if total_bytes == 0:
        return ""
    if total_bytes in (2, 4, 6, 8):
        return f"addq.l #{total_bytes},%%sp\\n\\t"
    return f"lea %%sp@({total_bytes}),%%sp\\n\\t"


def asm_uses_d1(args) -> bool:
    """インラインアセンブリの引数構築にd1レジスタが必要か判定する。"""
    for arg in args:
        if arg["argw"] in ("hb", "b"):
            return True
        if arg.get("or_mask") is not None:
            return True
    return False


def asm_block_with_or(code: str, args, cleanup_stack: bool = True):
    """引数の積み直し、OR加工、DOSコール実行を行うインラインasm本文を生成する。"""
    push_lines = []
    total = 0
    i = len(args) - 1
    # C呼び出し規約に合わせ、末尾の引数からDOSコール用スタックへ積み直す。
    while i >= 0:
        arg = args[i]
        w = arg["argw"]
        or_mask = arg.get("or_mask")
        if w == "b" and i > 0 and args[i - 1]["argw"] == "hb":
            # 隣接する上位・下位バイトはd1上で1ワードに合成する。
            hb_arg = args[i - 1]
            push_lines.append(f"move.b %[{hb_arg['name']}],%%d1\\n\\t")
            push_lines.append("lsl.w #8,%%d1\\n\\t")
            push_lines.append(f"move.b %[{arg['name']}],%%d1\\n\\t")
            push_lines.append("move.w %%d1,%%sp@-\\n\\t")
            total += 2
            i -= 2
            continue
        if w == "hb":
            push_lines.append(f"move.b %[{arg['name']}],%%d1\\n\\t")
            push_lines.append("lsl.w #8,%%d1\\n\\t")
            push_lines.append("move.w %%d1,%%sp@-\\n\\t")
            total += 2
            i -= 1
            continue
        if w == "b":
            push_lines.append("moveq #0,%%d1\\n\\t")
            push_lines.append(f"move.b %[{arg['name']}],%%d1\\n\\t")
            push_lines.append("move.w %%d1,%%sp@-\\n\\t")
            total += 2
            i -= 1
            continue
        # 通常のワード/ロング引数は、必要ならd1上でORマスクを適用する。
        if w in ("w", "c"):
            if w == "c":
                push_lines.append(f"move.w #{arg['value']},%%sp@-\\n\\t")
            elif or_mask is None:
                push_lines.append(f"move.w %[{arg['name']}],%%sp@-\\n\\t")
            else:
                push_lines.append(f"move.w %[{arg['name']}],%%d1\\n\\t")
                push_lines.append(f"or.w #{or_mask},%%d1\\n\\t")
                push_lines.append("move.w %%d1,%%sp@-\\n\\t")
            total += 2
        else:
            if or_mask is None:
                push_lines.append(f"move.l %[{arg['name']}],%%sp@-\\n\\t")
            else:
                push_lines.append(f"move.l %[{arg['name']}],%%d1\\n\\t")
                if or_mask == 0x80000000:
                    push_lines.append("bset #31,%%d1\\n\\t")
                else:
                    push_lines.append(f"or.l #{or_mask},%%d1\\n\\t")
                push_lines.append("move.l %%d1,%%sp@-\\n\\t")
            total += 4
        i -= 1
    body = "".join(push_lines)
    body += f".short {code}\\n\\t"
    if cleanup_stack:
        body += cleanup_asm(total)
    return body


def proto_from_args(args):
    """引数情報からC関数の仮引数リストを生成する。"""
    proto = ", ".join(
        format_param_decl(arg["ctype"], arg["name"])
        for arg in args
        if arg["argw"] != "c"
    )
    return proto or "void"


def asm_inputs(args):
    """引数情報からGCCインラインasmの入力オペランド一覧を生成する。"""
    return ", ".join(
        f"[{arg['name']}]\"g\"({arg['name']})" for arg in args if arg["argw"] != "c"
    )


def format_param_decl(ctype: str, name: str) -> str:
    """C型と引数名を、関数プロトタイプで使う宣言へ整形する。"""
    t = (ctype or "").strip()
    if "%" in t:
        return t.replace("%", name)
    if not t:
        return name
    if re.search(r"[A-Za-z0-9_]$", t):
        return f"{t} {name}"
    return f"{t}{name}"


def asm_c_string_lines(asm_str: str, tail: str = ""):
    """asm本文をCソースへ埋め込める文字列リテラルの行一覧へ変換する。"""
    token = "\\n\\t"
    parts = asm_str.split(token)
    out = []
    for i, part in enumerate(parts):
        is_last = i == len(parts) - 1
        if is_last and part == "":
            continue
        suffix = token if not is_last else ""
        out.append(f'"{part}{suffix}"')
    if tail:
        out.append(f'"{tail}"')
    return out


def wrap_with_callee_saved_preservation(asm_str: str, enabled: bool, abi: str) -> str:
    """必要に応じてasm本文をcallee-savedレジスタの保存・復帰命令で囲む。"""
    if not enabled:
        return asm_str
    # GCC のインラインアセンブラでは、固定レジスタ名の % を %% と記述する。
    regs = callee_saved_regs_for_abi(abi).replace("%", "%%")
    return (
        f"movem.l {regs},%%sp@-\\n\\t"
        + asm_str
        + f"movem.l %%sp@+,{regs}\\n\\t"
    )


def movem_reglist_for_count(count: int) -> str:
    """引数数に対応する一時レジスタのmovemリストを返す。"""
    if count == 2:
        return "%d0-%d1"
    if count == 3:
        return "%d0-%d1/%a0"
    if count == 4:
        return "%d0-%d1/%a0-%a1"
    return ""


def emit_inline_header(rows, out_path: Path, abi: str = ABI_GCC, override_index=None):
    """全DOSコールのインライン関数ヘッダーを生成する。"""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "#ifndef _DOS_INLINE_H_",
        "#define _DOS_INLINE_H_",
        "/* automatically generated from doscall.csv */",
        "",
        "#ifndef __DOS_INLINE__",
        "#define __DOS_INLINE__",
        "#endif",
        "#include <x68k/dos.h>",
        "",
        "__BEGIN_DECLS",
        "",
    ]
    # CSVの各有効行を、同名のstatic inline関数へ変換する。
    for row in rows:
        number = cell(row, COL_DOS_CALL_NUMBER)
        if number == "":
            lines.append("/*----*/")
            lines.append("")
            continue
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_DOS_CALL_NAME)
        if is_define_only_row(row):
            continue
        func = c_func_name_from_call_name(call_name)
        if not func:
            continue
        sections = resolve_override_sections(override_index, call_name)
        if sections is not None and "inline" in sections:
            # 個別実装があるAPIは自動生成せず、override本文をそのまま採用する。
            inline_text = sections["inline"]
            if inline_text:
                lines.extend(inline_text.splitlines())
            lines.append("")
            continue
        ret, is_noreturn, is_const, clobbers_all_regs = parse_return_type(
            cell(row, COL_RETURN_TYPE)
        )
        code = call_literal(number)
        desc = cell(row, COL_DESCRIPTION)
        args = parse_args(row)
        proto = proto_from_args(args)
        comment_name = normalized_call_name(call_name)
        lines.append(f"/* {code} {comment_name}: {desc} */")
        attr = function_attribute(is_noreturn, is_const)
        if attr:
            lines.append(attr)
        lines.append(f"static __inline__ {ret} {func}({proto}) {{")
        asm_str = asm_block_with_or(code, args, cleanup_stack=not is_noreturn)
        # 全レジスタ破壊APIではABI上の保存対象をasm本文の前後で退避する。
        asm_str = wrap_with_callee_saved_preservation(
            asm_str, clobbers_all_regs and not is_noreturn, abi
        )
        inputs = asm_inputs(args)
        d1_clobber = ",\"d1\"" if asm_uses_d1(args) or clobbers_all_regs else ""
        if clobbers_all_regs:
            extra_reg_clobbers = "".join(
                f',"{reg}"'
                for reg in ABI_INLINE_EXTRA_CLOBBERS_FOR_ALL_REGS.get(
                    abi, ABI_INLINE_EXTRA_CLOBBERS_FOR_ALL_REGS[ABI_GCC]
                )
            )
        else:
            extra_reg_clobbers = ""
        if ret == "void":
            lines.append("    __asm__ __volatile__ (")
            for s in asm_c_string_lines(asm_str):
                lines.append(f"        {s}")
            if inputs:
                lines.append(
                    f"        : : {inputs} : \"d0\"{d1_clobber}{extra_reg_clobbers},\"cc\",\"memory\");"
                )
            else:
                lines.append(
                    f"        : : : \"d0\"{d1_clobber}{extra_reg_clobbers},\"cc\",\"memory\");"
                )
            if is_noreturn:
                lines.append("    __builtin_unreachable();")
            else:
                lines.append("    return;")
        else:
            lines.append("    register long _ret __asm__(\"d0\");")
            lines.append("    __asm__ __volatile__ (")
            for s in asm_c_string_lines(asm_str):
                lines.append(f"        {s}")
            if inputs:
                lines.append(
                    f"        : [ret]\"=r\"(_ret) : {inputs} : \"cc\"{d1_clobber}{extra_reg_clobbers},\"memory\");"
                )
            else:
                lines.append(
                    f"        : [ret]\"=r\"(_ret) : : \"cc\"{d1_clobber}{extra_reg_clobbers},\"memory\");"
                )
            if is_noreturn:
                lines.append("    __builtin_unreachable();")
            else:
                lines.append(f"    return ({ret})_ret;")
        lines.append("}")
        lines.append("")
    lines += [
        "__END_DECLS",
        "",
        "#endif /* _DOS_INLINE_H_ */",
    ]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def emit_proto_header(rows, out_path: Path):
    """ライブラリ関数のプロトタイプ宣言ヘッダーを生成する。"""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "#ifndef _DOS_PROTO_H_",
        "#define _DOS_PROTO_H_",
        "/* automatically generated from doscall.csv */",
        "",
        "#include <x68k/dos.h>",
        "",
        "__BEGIN_DECLS",
        "",
    ]
    # ヘッダー専用行とdefine専用行を除き、外部関数の宣言を並べる。
    for row in rows:
        number = cell(row, COL_DOS_CALL_NUMBER)
        if number == "":
            lines.append("")
            continue
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_DOS_CALL_NAME)
        if is_define_only_row(row):
            continue
        func = c_func_name_from_call_name(call_name)
        if not func:
            continue
        ret, is_noreturn, is_const, _clobbers_all_regs = parse_return_type(
            cell(row, COL_RETURN_TYPE)
        )
        args = parse_args(row)
        proto = proto_from_args(args)
        attr_text = function_attribute(is_noreturn, is_const)
        attr = f" {attr_text}" if attr_text else ""
        lines.append(f"{ret} {func}({proto}){attr};")
    lines += [
        "",
        "__END_DECLS",
        "",
        "#endif /* _DOS_PROTO_H_ */",
    ]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def emit_call_number_header(rows, out_path: Path):
    """DOSコール番号を定義するマクロヘッダーを生成する。"""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "#ifndef _DOSCALL_H_",
        "#define _DOSCALL_H_",
        "/* automatically generated from doscall.csv */",
        "",
    ]
    # 同名APIが複数行に現れても、番号マクロは最初の1回だけ生成する。
    seen = set()
    for row in rows:
        number = cell(row, COL_DOS_CALL_NUMBER)
        if number == "":
            lines.append("")
            continue
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_DOS_CALL_NAME)
        if is_no_define_api_name(call_name):
            continue
        macro = macro_name_from_call_name(call_name)
        if not macro or macro in seen:
            continue
        code = call_literal(number)
        desc = cell(row, COL_DESCRIPTION)
        if desc:
            lines.append(f"#define {macro:15} {code}   /* {desc} */")
        else:
            lines.append(f"#define {macro:15} {code}")
        seen.add(macro)
    lines += ["", "#endif"]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def emit_lib_source(
    rows,
    out_dir: Path,
    abi: str = ABI_GCC,
    override_index=None,
):
    """各DOSコールを呼び出すライブラリ用アセンブリソースを生成する。"""
    out_dir.mkdir(parents=True, exist_ok=True)
    for row in rows:
        # ここで実体の .S 実装を生成しない行はスキップする。
        # - コメント行: メタ情報のみ
        # - define 専用行: 番号マクロのみ
        number = cell(row, COL_DOS_CALL_NUMBER)
        if is_comment_row_number(number):
            continue
        call_name = cell(row, COL_DOS_CALL_NAME)
        if is_define_only_row(row):
            continue
        func = c_func_name_from_call_name(call_name)
        if not func:
            continue
        ret, is_noreturn, _is_const, clobbers_all_regs = parse_return_type(
            cell(row, COL_RETURN_TYPE)
        )
        code = call_literal(number or "0xff00")
        desc = cell(row, COL_DESCRIPTION)
        args = parse_args(row)
        proto = proto_from_args(args)

        ident = ident_from_call_name(normalized_call_name(call_name))
        if not ident:
            ident = normalize_filename_token(func, "doscall")
        code_val = call_code_value(number or "0xff00")
        out_path = out_dir / f"dos{code_val & 0xffff:04x}_{ident}.S"

        sections = resolve_override_sections(override_index, call_name)
        if sections is not None and "lib" in sections:
            lib_text = filter_override_abi_lines(sections["lib"], abi)
            out_path.write_text(lib_text + "\n", encoding="utf-8", newline="\n")
            continue

        lines = []
        comment_name = normalized_call_name(call_name)
        lines.append(f"/* {code} {comment_name}: {desc} */")
        lines.append(f"/* {ret} {func}({proto}); */")
        lines.append("")
        lines.append("\t.text")
        lines.append("\t.even")
        lines.append(f"\t.global {func}")
        lines.append(f"\t.type {func}, @function")
        lines.append("")
        lines.append(f"{func}:")

        callee_saved_regs = callee_saved_regs_for_abi(abi)
        callee_saved_stack_bytes = callee_saved_stack_bytes_for_abi(abi)
        preserve_callee_saved = clobbers_all_regs and not is_noreturn
        stack_arg_base = 4 + (
            callee_saved_stack_bytes if preserve_callee_saved else 0
        )

        if preserve_callee_saved:
            lines.append(f"\tmovem.l\t{callee_saved_regs}, %sp@-")

        # caller_slot は「関数入口時点での各非定数引数のスタック位置」を保持する。
        # これを基準に、すでに積んだバイト数(total)を加味して
        # 呼び出し側スタックから DOS コール用スタックへコピーする。
        caller_slot = 0
        for arg in args:
            if arg["argw"] != "c":
                arg["caller_slot"] = caller_slot
                caller_slot += 1


        # 汎用経路: 最適化条件に合わない場合は、DOS コール用の引数並びを
        # ここで明示的に「積み直す」。
        # - 右から左へ処理する理由:
        #   C の呼び出し規約どおり、最終的に左側引数が高位アドレス側に並ぶようにするため。
        # - total の役割:
        #   既に %sp@- で積んだ総バイト数。これだけ元の引数位置が後ろへずれるので、
        #   呼び出し側スタックから読み出すオフセット補正と、最後の %sp 復帰に共通利用する。
        total = 0
        i = len(args) - 1
        while i >= 0:
            arg = args[i]

            # hb + b は 1 ワードとして詰める特別経路。
            # 例: dNhb / dNb を別々に受け取る API。
            #   hb は上位 8bit なので一度 d0 に入れて 8bit 左シフトし、
            #   続いて b を下位 8bit として重ね、最後に move.w で 1 語として push する。
            if arg["argw"] == "b" and i > 0 and args[i - 1]["argw"] == "hb":
                hb_arg = args[i - 1]
                # 4 は戻りアドレス分。caller_slot*4 は引数スロット。
                # total を加えることで、これまでに積んだ分だけ後ろへずれた実位置を読む。
                hb_src_off = stack_arg_base + hb_arg["caller_slot"] * 4 + total
                lines.append(f"\tmove.b\t%sp@({hb_src_off + 3}), %d0")
                lines.append("\tlsl.w\t#8, %d0")
                b_src_off = stack_arg_base + arg["caller_slot"] * 4 + total
                lines.append(f"\tmove.b\t%sp@({b_src_off + 3}), %d0")
                lines.append("\tmove.w\t%d0, %sp@-")
                # hb+b で 1 ワード積んだので +2。
                total += 2
                # 2 引数まとめて処理したため i を 2 減らす。
                i -= 2
                continue

            # hb 単独は下位バイトを 0 としてワード化する。
            if arg["argw"] == "hb":
                src_off = stack_arg_base + arg["caller_slot"] * 4 + total
                lines.append(f"\tmove.b\t%sp@({src_off + 3}), %d0")
                lines.append("\tlsl.w\t#8, %d0")
                lines.append("\tmove.w\t%d0, %sp@-")
                total += 2
                i -= 1
                continue

            # b 単独は上位バイトを 0 としてワード化する。
            if arg["argw"] == "b":
                lines.append("\tmoveq\t#0, %d0")
                src_off = stack_arg_base + arg["caller_slot"] * 4 + total
                lines.append(f"\tmove.b\t%sp@({src_off + 3}), %d0")
                lines.append("\tmove.w\t%d0, %sp@-")
                total += 2
                i -= 1
                continue

            # 連続する long 引数は movem.l に束ねる最適化。
            # さらに、直前に word 引数が 1 つある場合は
            # [word + long ...] を最大4引数分まとめて読み出す。
            # 条件:
            # - long 引数(argw=l)が「caller_slot 連番」で続くこと
            # - 最大 4 個まで（利用レジスタ d0/d1/a0/a1 の都合）
            # 効果:
            # - move.l の連打より命令数を減らす
            # - 読み出し/書き込みをそれぞれ 1 命令に集約できる
            if arg["argw"] == "l" and arg.get("or_mask") is None:
                run = [i]
                prev_slot = arg["caller_slot"]
                j = i - 1
                while len(run) < 4 and j >= 0:
                    cand = args[j]
                    if (
                        cand["argw"] == "l"
                        and cand.get("or_mask") is None
                        and cand["caller_slot"] == prev_slot - 1
                    ):
                        run.append(j)
                        prev_slot = cand["caller_slot"]
                        j -= 1
                    else:
                        break

                # [word + long...] 特化経路。
                # word スロット先頭(= word 実値の 2 バイト前)からまとめてロードし、
                # 残り long を先に push し、先頭レジスタの下位 word を最後に push する。
                use_word_long_movem = False
                if (
                    len(run) == 3
                    and j >= 0
                    and args[j]["argw"] == "w"
                    and args[j].get("or_mask") is None
                    and args[j]["caller_slot"] == prev_slot - 1
                ):
                    reglist = movem_reglist_for_count(4)
                    if reglist:
                        word_src_off = stack_arg_base + args[j]["caller_slot"] * 4 + total
                        lines.append(f"\tmovem.l\t%sp@({word_src_off}), {reglist}")
                        lines.append("\tmovem.l\t%d1/%a0-%a1, %sp@-")
                        lines.append("\tmove.w\t%d0, %sp@-")

                        total += 2 + 4 * len(run)
                        i -= len(run) + 1
                        use_word_long_movem = True

                if use_word_long_movem:
                    continue

                use_movem = len(run) >= 3
                if use_movem:
                    reglist = movem_reglist_for_count(len(run))
                    # run は右から左へ収集されるため、実メモリ上の先頭は run[-1] 側。
                    # その caller_slot を基準に読み出し開始位置を計算する。
                    low_slot = args[run[-1]]["caller_slot"]
                    src_off = stack_arg_base + low_slot * 4 + total
                    lines.append(f"\tmovem.l\t%sp@({src_off}), {reglist}")
                    lines.append(f"\tmovem.l\t{reglist}, %sp@-")
                    total += 4 * len(run)
                    i -= len(run)
                    continue

            w = arg["argw"]
            if w in ("w", "c"):
                if w == "c":
                    if arg["value"]:
                        lines.append(f"\tmove.w\t#{arg['value']}, %sp@-")
                    else:
                        lines.append(f"\tclr.w\t%sp@-")
                else:
                    src_off = stack_arg_base + arg["caller_slot"] * 4 + total
                    or_mask = arg.get("or_mask")
                    if or_mask is None:
                        # 呼び出し側の1スロットは 32bit 幅で扱っているため、
                        # word 実引数の実データはスロット下位側（+2）にある。
                        lines.append(f"\tmove.w\t%sp@({src_off + 2}), %sp@-")
                    else:
                        lines.append(f"\tmove.w\t%sp@({src_off + 2}), %d0")
                        lines.append(f"\tor.w\t#{or_mask}, %d0")
                        lines.append("\tmove.w\t%d0, %sp@-")
                total += 2
            else:
                src_off = stack_arg_base + arg["caller_slot"] * 4 + total
                or_mask = arg.get("or_mask")
                if or_mask is None:
                    lines.append(f"\tmove.l\t%sp@({src_off}), %sp@-")
                else:
                    # OR マスク付きは一度 d0 へ読み、ビット演算してから push する。
                    lines.append(f"\tmove.l\t%sp@({src_off}), %d0")
                    if or_mask == 0x80000000:
                        # bit31 だけ立てる特殊ケースは bset を使う。
                        lines.append("\tbset\t#31, %d0")
                    else:
                        lines.append(f"\tor.l\t#{or_mask}, %d0")
                    lines.append("\tmove.l\t%d0, %sp@-")
                total += 4
            i -= 1

        lines.append(f"\t.short\t{code}")
        if not is_noreturn:
            # 後始末は、汎用経路でこの関数自身が積んだ分だけを戻す。
            if total in (2, 4, 6, 8):
                lines.append(f"\taddq.l\t#{total}, %sp")
            elif total != 0:
                lines.append(f"\tlea\t%sp@({total}), %sp")
            if preserve_callee_saved:
                lines.append(f"\tmovem.l\t%sp@+, {callee_saved_regs}")
            lines.append("\trts")

        out_path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def main():
    """コマンドライン引数を解析し、すべての生成処理を実行する。"""
    parser = argparse.ArgumentParser(
        description="doscall.csvからinline header/prototype header/library functionを生成する。"
    )
    parser.add_argument("--csv", type=Path, default=Path("doscall.csv"))
    parser.add_argument("--inline-h", type=Path, default=Path("out/dos_inline.h"))
    parser.add_argument("--proto-h", type=Path, default=Path("out/dos_proto.h"))
    parser.add_argument(
        "--def-h",
        type=Path,
        default=Path("out/doscall.h"),
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
    args = parser.parse_args()

    rows = load_csv_rows(args.csv)
    override_index = load_override_index(args.override_dir)
    emit_inline_header(rows, args.inline_h, args.abi, override_index)
    emit_proto_header(rows, args.proto_h)
    emit_call_number_header(rows, args.def_h)
    emit_lib_source(rows, args.out_dir, args.abi, override_index)


if __name__ == "__main__":
    main()
