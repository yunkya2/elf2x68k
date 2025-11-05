#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	install.sh
#
#		X68k 固有設定、ライブラリを m68k-xelf toolchain にインストールする
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2023-2025 Yuichi Nakamura (@yunkya2)
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

# 共通設定を読み込み
. scripts/common.sh

cp src/m68k-xelf-ld.x ${INSTALL_DIR}/bin/m68k-xelf-ld.x
rm -f ${INSTALL_DIR}/m68k-elf/bin/ld.x
ln ${INSTALL_DIR}/bin/m68k-xelf-ld.x ${INSTALL_DIR}/m68k-elf/bin/ld.x

cp src/m68k-xelf-bas ${INSTALL_DIR}/bin
cp bas2c/bas2c.py ${INSTALL_DIR}/bin
cp bas2c/bas2c.def ${INSTALL_DIR}/bin
cp unlha/unlha.py ${INSTALL_DIR}/bin
cp src/m68k-xelf-gdb ${INSTALL_DIR}/bin

cp src/elf2x68k.py ${INSTALL_DIR}/bin
cp src/x68k2elf.py ${INSTALL_DIR}/bin
cp src/x68k.ld ${INSTALL_DIR}/m68k-elf/lib
cp src/x68k.specs ${INSTALL_DIR}/m68k-elf/lib
cp src/x68knodos.specs ${INSTALL_DIR}/m68k-elf/lib
cp src/c++small.specs ${INSTALL_DIR}/m68k-elf/lib
cp src/nano.specs ${INSTALL_DIR}/m68k-elf/lib
cp src/xc.specs.tmpl ${INSTALL_DIR}/m68k-elf/lib
cp src/install-xclib.sh ${INSTALL_DIR}

m68k-xelf-gcc -dumpspecs > ${INSTALL_DIR}/lib/gcc/m68k-elf/specs
cat src/x68k.specs >> ${INSTALL_DIR}/lib/gcc/m68k-elf/specs
mv ${INSTALL_DIR}/lib/gcc/m68k-elf/specs ${INSTALL_DIR}/lib/gcc/m68k-elf/[0-9]*

(cd src/libx68k; make) || exit 1
cp src/libx68k/libx68k.a ${INSTALL_DIR}/m68k-elf/lib
cp src/libx68k/libx68knodos.a ${INSTALL_DIR}/m68k-elf/lib
cp src/libx68k/libiocs/libx68kiocs.a ${INSTALL_DIR}/m68k-elf/lib
cp src/libx68k/libdos/libx68kdos.a ${INSTALL_DIR}/m68k-elf/lib
cp src/libx68k/libsocket/libsocket.a ${INSTALL_DIR}/m68k-elf/lib
cp src/libx68k/libpthread/libpthread.a ${INSTALL_DIR}/m68k-elf/lib
cp src/libx68k/crt0.o ${INSTALL_DIR}/m68k-elf/lib/x68kcrt0.o
cp src/libx68k/crt0nodos.o ${INSTALL_DIR}/m68k-elf/lib/x68kcrt0nodos.o

mkdir -p ${INSTALL_DIR}/m68k-elf/include/x68k
cp -r src/libx68k/x68k ${INSTALL_DIR}/m68k-elf/include

mkdir -p ${INSTALL_DIR}/m68k-elf/sys-include/sys
cp src/_default_fcntl.h ${INSTALL_DIR}/m68k-elf/sys-include/sys
cp src/dirent.h ${INSTALL_DIR}/m68k-elf/sys-include/sys
cp src/features.h ${INSTALL_DIR}/m68k-elf/sys-include/sys
cp -r src/libx68k/libsocket/include/* ${INSTALL_DIR}/m68k-elf/sys-include
cp -r src/libx68k/libpthread/include/* ${INSTALL_DIR}/m68k-elf/sys-include

GIT_REPO_VERSION=`git describe --tags --always`
cat > ${INSTALL_DIR}/README << EOF
elf2x68k: m68k-xelf cross toolchain for X680x0
version: ${GIT_REPO_VERSION}
URL: https://github.com/yunkya2/elf2x68k/
EOF

if [ "${HOST_OPTION}" != "" ]; then
    cp /usr/x86_64-w64-mingw32/bin/libiconv-2.dll ${INSTALL_DIR}/bin
    cp /usr/x86_64-w64-mingw32/lib/zlib1.dll ${INSTALL_DIR}/bin
    cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll ${INSTALL_DIR}/bin
    cp /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libgcc_s_seh-1.dll ${INSTALL_DIR}/bin
    cp /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libstdc++-6.dll ${INSTALL_DIR}/bin

fi

echo ""
echo "-----------------------------------------------------------------------------"
echo "Installed X68k support files into m68k-xelf toolchain."
echo "-----------------------------------------------------------------------------"
echo ""

exit 0
