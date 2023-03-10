#!/bin/sh

set -e

M68K_TOOLCHAIN=${XDEV68K_DIR}/m68k-toolchain

if [ ! -e ${M68K_TOOLCHAIN} ]; then
	echo "m68k toolchain does not exist"
	exit 1
fi

rm -f ${M68K_TOOLCHAIN}/bin/m68k-elf-ld.x
rm -f ${M68K_TOOLCHAIN}/m68k-elf/bin/ld.x

rm -f ${M68K_TOOLCHAIN}/bin/elf2x68k.py
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/x68k.ld
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/x68k.specs
rm -f ${M68K_TOOLCHAIN}/lib/gcc/m68k-elf/specs
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libx68k.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libx68knodos.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libiocs.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/libdos.a
rm -f ${M68K_TOOLCHAIN}/m68k-elf/lib/x68crt0*.o
rm -rf ${M68K_TOOLCHAIN}/m68k-elf/include/x68k
rm -rf ${M68K_TOOLCHAIN}/m68k-elf/sys-include/sys
rmdir ${M68K_TOOLCHAIN}/m68k-elf/sys-include

echo "Uninstalled elf2x68k script from m68k-elf-gcc toolchain."
