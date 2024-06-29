#!/bin/bash
#------------------------------------------------------------------------------
#
#	getdefsp.sh
#
#		無償公開版 Human68k のスプライトパターンエディタ DEFSPTOOL.BAS を取得して
#		BAStoC 変換のためのパッチを当てる
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

HUMAN_ARCHIVE="HUMAN302.LZH"
HUMAN_URL="http://retropc.net/x68000/software/sharp/human302/${HUMAN_ARCHIVE}"

ROOT_DIR="${PWD}"
TEMP_DIR="${ROOT_DIR}/temp"
DOWNLOAD_DIR="${ROOT_DIR}/download"

# ソースコードを UTF-8 に変換し、改行コードを CRLF → LF に変換する
copysrc() {
    iconv -f cp932 -t utf-8 $1 | tr -d \\r > $2
}
# retropc.net から公開版 Human68k システムディスクをダウンロードする
mkdir -p ${DOWNLOAD_DIR}
cd ${DOWNLOAD_DIR}
wget -nc ${HUMAN_URL}

# ダウンロードしたシステムディスクから DEFSPTOOL.BAS を取り出す
rm -rf ${TEMP_DIR}
mkdir -p ${TEMP_DIR}
cd ${TEMP_DIR}
unlha.py x ${DOWNLOAD_DIR}/${HUMAN_ARCHIVE}

# DEFSPTOOL.BAS のソースコードには 1 箇所だけ X68k 独自文字コードが使われていて
# SJIS -> UTF-8 変換が出来ないため、その箇所を修正する
echo -n ' "-'|dd of=ETC/DEFSPTOOL.BAS bs=1 seek=20968 conv=notrunc

# UTF-8 に変換してコピー (ヘルプファイルは SJIS のまま)
copysrc ETC/DEFSPTOOL.BAS ${ROOT_DIR}/DEFSPTOOL.BAS
cp ETC/DEFSPTOOL.HLP ${ROOT_DIR}

# BAStoC 変換用のパッチを当てる
# (XC ライブラリディスクのサンプルに入っていた DEF.BAS と同じもの)
# 主に時間待ちのループ回数が少なすぎる箇所の修正
cd ${ROOT_DIR}
patch -p1 < defsp.patch

rm -rf ${TEMP_DIR}
exit 0
