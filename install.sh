#!/bin/sh

set -e

M68K_TOOLCHAIN=${XDEV68K_DIR}/m68k-toolchain

if [ ! -e ${M68K_TOOLCHAIN} ]; then
	echo "m68k toolchain does not exist"
	exit 1
fi

rm ${M68K_TOOLCHAIN}/bin/m68k-elf-ld
rm ${M68K_TOOLCHAIN}/m68k-elf/bin/ld
cp src/m68k-elf-ld ${M68K_TOOLCHAIN}/bin/m68k-elf-ld
ln ${M68K_TOOLCHAIN}/bin/m68k-elf-ld ${M68K_TOOLCHAIN}/m68k-elf/bin/ld

cp src/elf2x68k.py ${M68K_TOOLCHAIN}/bin
cp src/x68k.ld ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/x68k.specs ${M68K_TOOLCHAIN}/m68k-elf/lib

(cd src/libx68k;make)
cp src/libx68k/libx68k.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libiocs/libiocs.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libdos/libdos.a ${M68K_TOOLCHAIN}/m68k-elf/lib
mkdir -p ${M68K_TOOLCHAIN}/m68k-elf/include/x68k
cp -r src/libx68k/x68k ${M68K_TOOLCHAIN}/m68k-elf/include

echo "Installed elf2x68k script into m68k-elf-gcc toolchain."
