#!/bin/sh

set -e

M68K_TOOLCHAIN=${XDEV68K_DIR}/m68k-toolchain

if [ ! -e ${M68K_TOOLCHAIN} ]; then
	echo "m68k toolchain does not exist"
	exit 1
fi

cp src/m68k-elf-ld.x ${M68K_TOOLCHAIN}/bin/m68k-elf-ld.x
rm -f ${M68K_TOOLCHAIN}/m68k-elf/bin/ld.x
ln ${M68K_TOOLCHAIN}/bin/m68k-elf-ld.x ${M68K_TOOLCHAIN}/m68k-elf/bin/ld.x

cp src/elf2x68k.py ${M68K_TOOLCHAIN}/bin
cp src/x68k.ld ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/x68k.specs ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/x68knodos.specs ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/x68k.specs ${M68K_TOOLCHAIN}/lib/gcc/m68k-elf/specs

(cd src/libx68k;make)
cp src/libx68k/libx68k.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libx68knodos.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libiocs/libiocs.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/libdos/libdos.a ${M68K_TOOLCHAIN}/m68k-elf/lib
cp src/libx68k/crt0.o ${M68K_TOOLCHAIN}/m68k-elf/lib/x68kcrt0.o
cp src/libx68k/crt0nodos.o ${M68K_TOOLCHAIN}/m68k-elf/lib/x68kcrt0nodos.o

mkdir -p ${M68K_TOOLCHAIN}/m68k-elf/include/x68k
cp -r src/libx68k/x68k ${M68K_TOOLCHAIN}/m68k-elf/include

echo "Installed elf2x68k script into m68k-elf-gcc toolchain."
