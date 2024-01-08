#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	install.sh
#
#		X68k 固有設定、ライブラリを m68k-xelf toolchain にインストールする
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2023,2024 Yuichi Nakamura (@yunkya2)
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

set -e

M68K_TOOLCHAIN=m68k-xelf
export PATH="${PWD}/${M68K_TOOLCHAIN}/bin:${PATH}"

cp src/m68k-xelf-ld.x ${M68K_TOOLCHAIN}/bin/m68k-xelf-ld.x
rm -f ${M68K_TOOLCHAIN}/m68k-elf/bin/ld.x
ln ${M68K_TOOLCHAIN}/bin/m68k-xelf-ld.x ${M68K_TOOLCHAIN}/m68k-elf/bin/ld.x

cp src/elf2x68k.py ${M68K_TOOLCHAIN}/bin
cp src/x68k2elf.py ${M68K_TOOLCHAIN}/bin
cp src/x68k.ld ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/x68k.specs ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/x68knodos.specs ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/xc.specs.tmpl ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/install-xclib.sh ${M68K_TOOLCHAIN}

${M68K_TOOLCHAIN}/bin/m68k-xelf-gcc -dumpspecs > ${M68K_TOOLCHAIN}/lib/gcc/m68k-elf/specs
cat src/x68k.specs >> ${M68K_TOOLCHAIN}/lib/gcc/m68k-elf/specs
mv ${M68K_TOOLCHAIN}/lib/gcc/m68k-elf/specs ${M68K_TOOLCHAIN}/lib/gcc/m68k-elf/[0-9]*

(cd src/libx68k; make) || exit 1
cp src/libx68k/libx68k.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libx68knodos.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libiocs/libiocs.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libdos/libdos.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/crt0.o ${M68K_TOOLCHAIN}/m68k-elf/lib/x68kcrt0.o
cp src/libx68k/crt0nodos.o ${M68K_TOOLCHAIN}/m68k-elf/lib/x68kcrt0nodos.o

mkdir -p ${M68K_TOOLCHAIN}/m68k-elf/include/x68k
cp -r src/libx68k/x68k ${M68K_TOOLCHAIN}/m68k-elf/include

mkdir -p ${M68K_TOOLCHAIN}/m68k-elf/sys-include/sys
cp src/_default_fcntl.h ${M68K_TOOLCHAIN}/m68k-elf/sys-include/sys

DATE=`date +%Y%m%d`
cat > ${M68K_TOOLCHAIN}/README << EOF
elf2x68k: m68k-xelf cross toolchain for X680x0
version: ${DATE}
URL: https://github.com/yunkya2/elf2x68k/
EOF

echo ""
echo "-----------------------------------------------------------------------------"
echo "Installed X68k support files into m68k-xelf toolchain."
echo "-----------------------------------------------------------------------------"
echo ""

exit 0
