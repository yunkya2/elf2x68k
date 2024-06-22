#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	uninstall.sh
#
#		X68k 固有設定、ライブラリを m68k-xelf toolchain から削除する
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

rm -f ${M68K_TOOLCHAIN}/README
rm -f ${M68K_TOOLCHAIN}/bin/m68k-xelf-ld.x
rm -f ${M68K_TOOLCHAIN}/m68k-elf/bin/ld.x

rm -f ${M68K_TOOLCHAIN}/bin/m68k-xelf-bas
rm -f ${M68K_TOOLCHAIN}/bin/bas2c.py
rm -f ${M68K_TOOLCHAIN}/bin/bas2c.def
rm -f ${M68K_TOOLCHAIN}/bin/unlha.py

rm -f ${M68K_TOOLCHAIN}/bin/elf2x68k.py
rm -f ${M68K_TOOLCHAIN}/bin/x68k2elf.py
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/x68k.ld
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/x*.specs*
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/c++small.specs
rm -f ${M68K_TOOLCHAIN}/lib/gcc/m68k-elf/[0-9]*/specs
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libx68k.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libx68knodos.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libx68kiocs.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libx68kdos.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/x68kcrt0*.o
rm -rf ${M68K_TOOLCHAIN}/m68k-elf/include/x68k
rm -rf ${M68K_TOOLCHAIN}/m68k-elf/sys-include/sys
rm -rf ${M68K_TOOLCHAIN}/m68k-elf/sys-include

rm -rf ${M68K_TOOLCHAIN}/download
rm -rf ${M68K_TOOLCHAIN}/install-xclib.sh
rm -rf ${M68K_TOOLCHAIN}/xc-elf
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libiocs.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libdos.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libbas.a

echo ""
echo "-----------------------------------------------------------------------------"
echo "Uninstalled X68k support files from m68k-xelf toolchain."
echo "-----------------------------------------------------------------------------"
echo ""

exit 0
