#!/bin/bash
#------------------------------------------------------------------------------
#
#	getxsp.sh
#
#		よっしん氏 (@yosshin4004) 作のスプライト管理ライブラリ XSP を取得して
#		elf2x68k でのビルド用にパッチを当てる
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2024 Yuichi Nakamura (@yunkya2)
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#	    http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#
#------------------------------------------------------------------------------

XSP_REPO="x68k_xsp"
XSP_URL="https://github.com/yosshin4004/${XSP_REPO}.git"
XSP_COMMITID="858a88ed1d0c05cf917e963c2f52daabc0c21f8e"

ROOT_DIR="${PWD}"
DOWNLOAD_DIR="${ROOT_DIR}/download"
REPO_DIR="${DOWNLOAD_DIR}/${XSP_REPO}"

# ソースコードを UTF-8 に変換し、改行コードを CRLF → LF に変換する
copysrc() {
    iconv -f cp932 -t utf-8 $1 | tr -d \\r > $2
}

# github から XSP を clone する
rm -rf ${DOWNLOAD_DIR}
mkdir -p ${DOWNLOAD_DIR}
cd ${DOWNLOAD_DIR}
git clone ${XSP_URL}
cd ${REPO_DIR}
git checkout ${XSP_COMMITID}

cd ${REPO_DIR}

mkdir -p ${ROOT_DIR}/lib
mkdir -p ${ROOT_DIR}/data

# XSP オブジェクトファイルを ELF 形式に変換してコピー
x68k2elf.py XSP/XSP2lib.o ${ROOT_DIR}/lib/xsp2lib.o
copysrc XSP/XSP2lib.H ${ROOT_DIR}/lib/xsp2lib.h

# PCM8Afnc オブジェクトファイルを ELF 形式に変換してコピー
x68k2elf.py PCM8Afnc/PCM8Afnc.o ${ROOT_DIR}/lib/pcm8afnc.o
copysrc PCM8Afnc/PCM8Afnc.H ${ROOT_DIR}/lib/pcm8afnc.h

# PCG90 オブジェクトファイルを ELF 形式に変換してコピー
# (C 用とアセンブラ用 API の名前が重複してしまうため、アンダーバーは外さずに変換)
x68k2elf.py -k PCG90/PCG90.o ${ROOT_DIR}/lib/pcg90.o
copysrc PCG90/PCG90.H ${ROOT_DIR}/lib/pcg90.h

# サンプルソースコードを UTF-8 に変換してコピー
copysrc SAMPLE/XSP_010/main.c ${ROOT_DIR}/xsp_010.c
copysrc SAMPLE/XSP_020/main.c ${ROOT_DIR}/xsp_020.c
copysrc SAMPLE/XSP_030/main.c ${ROOT_DIR}/xsp_030.c
copysrc SAMPLE/XSP_040/main.c ${ROOT_DIR}/xsp_040.c
copysrc SAMPLE/XSP_050/main.c ${ROOT_DIR}/xsp_050.c
copysrc SAMPLE/XSP_060/main.c ${ROOT_DIR}/xsp_060.c

# サンプルコードの利用するデータを data/ にコピー
cp SAMPLE/PANEL.PAL ${ROOT_DIR}/data
cp SAMPLE/PANEL.SP ${ROOT_DIR}/data
cp SAMPLE/XSP_030/ZAKO.frm ${ROOT_DIR}/data
cp SAMPLE/XSP_030/ZAKO.ref ${ROOT_DIR}/data
cp SAMPLE/XSP_030/ZAKO.xsp ${ROOT_DIR}/data

# elf2x68k 用のパッチを当てる
# 修正内容:
# - C 関数のシンボル名先頭にアンダーバーを付けない
# - ヘッダやデータファイルのパス名変更に対応
# - PCG データバッファのアドレスが word align されずアドレスエラーになる問題を修正
# - newlib に strmfe() がないので strcpy() + strcat() で代替
# - printf() がバッファリングされるため fflush() を追加
cd ${ROOT_DIR}
patch -p1 < xsp.patch

rm -rf ${DOWNLOAD_DIR}

exit 0
