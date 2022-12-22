#!/usr/bin/env python3
import sys
import os
import argparse
from struct import pack, unpack, calcsize

class ElfHeader:
    def __init__(self, fh):
        fh.seek(0)
        elfident = fh.read(16)
        assert elfident[0:4] == b'\x7fELF'
        (self.ei_cls, self.ei_data, self.ei_version,
         self.ei_osabi, self.ei_abiversion) = unpack("5b", elfident[4:9])
        assert self.ei_cls == 1         # ELF32
        assert self.ei_data == 2        # Big endian
        ehparse = ">2H5L6H"
        (self.type, self.machine,
         self.version, self.entry, self.phoff, self.shoff, self.flags,
         self.ehsize, self.phentsize, self.phnum, self.shentsize, self.shnum, self.shstrndx) \
            = unpack(ehparse, fh.read(calcsize(ehparse)))
        assert self.machine == 4        # Machine 68000

class ProgramHeader:
    def __init__(self, eh, fh):
        data = fh.read(eh.phentsize)
        (self.type, self.offset, self.vaddr, self.paddr,
         self.filesz, self.memsz, self.flags, self.align) = unpack(">8L", data)

    def __repr__(self):
        return "0x%02x 0x%06x 0x%08x 0x%08x 0x%06x 0x%06x 0x%02x 0x%02x" % \
            (self.type, self.offset, self.vaddr, self.paddr, self.filesz, self.memsz, self.flags, self.align)

class SectionHeader:
    def __init__(self, eh, fh):
        data = fh.read(eh.shentsize)
        (self.nameidx, self.type, self.flags, self.addr, self.offset,
         self.size, self.link, self.info, self.addralign, self.entsize) = unpack(">10L", data)
        self.name = ""
        self.relidx = None

    def __repr__(self):
        return "0x%02x 0x%02x 0x%08x 0x%06x 0x%06x %02d 0x%02x 0x%02x 0x%02x" % \
            (self.type, self.flags, self.addr, self.offset, self.size,
             self.link, self.info, self.addralign, self.entsize)

class Symbol:
    def __init__(self, eh, fh):
        symparse = ">3L2bH"
        data = fh.read(calcsize(symparse))
        (self.nameidx, self.value, self.size,
         self.info, self.other, self.shndx) = unpack(symparse, data)
        self.bind = self.info >> 4
        self.type = self.info & 0xf
        self.name = None

    def __repr__(self):
        return "0x%08x 0x%08x 0x%02x 0x%02x 0x%04x %s" % (
            self.value, self.size, self.info, self.other, self.shndx, self.name)

class X68kHeader:
    def __init__(self, base, entry, textsz, datasz, bsssz, relsz, symsz):
        (self.base, self.entry, self.textsz, self.datasz, self.bsssz, self.relsz, self.symsz) = \
            (base, entry, textsz, datasz, bsssz, relsz, symsz)

    def encode(self):
        return b'HU\0\0' + pack(">7L",
                                self.base, self.entry,
                                self.textsz, self.datasz, self.bsssz, self.relsz, self.symsz) + \
                           b'\0' * 32

# Convert ELF to X68k execute file (fixed load address)

def elf2x68k(fh):
    # Read ELF header
    eh = ElfHeader(fh)

    # Read Program headers
    fh.seek(eh.phoff)
    phlist = []
    for i in range(eh.phnum):
        ph = ProgramHeader(eh, fh)
        phlist.append(ph)

    # Read Section headers
    shlist = []
    sh_symtab = None
    fh.seek(eh.shoff)
    for i in range(eh.shnum):
        sh = SectionHeader(eh, fh)
        if sh.type == 2:                # SHT_SYMTAB
            sh_symtab = sh
        shlist.append(sh)

    # Read Symbol table
    symlist = []
    if sh_symtab:
        fh.seek(sh_symtab.offset)
        while fh.tell() - sh_symtab.offset < sh_symtab.size:
            sym = Symbol(eh, fh)
            symlist.append(sym)

        # Get symbol name from strtab
        sh_strtab = shlist[sh_symtab.link]
        fh.seek(sh_strtab.offset)
        strtab = fh.read(sh_strtab.size)
        for sym in symlist:
            sym.name = strtab[sym.nameidx:strtab.index(b'\0',sym.nameidx)].decode()

    # Read Section data
    baseaddr = -1
    curaddr = 0
    prevtype = -1
    contents = [ b'', b'', b'' ]
    for sh in shlist:
        if sh.flags & 2:                # SHF_ALLOC
            if baseaddr < 0:
                baseaddr = sh.addr
                curaddr = sh.addr
            if prevtype >= 0:
                contents[prevtype] += b'\0' * (sh.addr - curaddr)

            if sh.type == 1:            # SHT_PROGBITS
                fh.seek(sh.offset)
                if not sh.flags & 1:        # !SHF_WRITE    ... .text
                    prevtype = 0
                else:                       #               ... .data
                    prevtype = 1
                contents[prevtype] += fh.read(sh.size)
            elif sh.type == 8:           # SHT_NOBITS       ... .bss
                prevtype = 2
                contents[prevtype] += b'\0' * sh.size

            curaddr = sh.addr + sh.size

    # Create symbol table for X68k
    symtbl = b''
    for sym in symlist:
        if sym.bind != 1:               # STB_GLOBAL
            continue
        sh = shlist[sym.shndx] if sym.shndx < 0xff00 else None
        if sh and sh.flags & 2:         # SHF_ALLOC
            symtype = 0
            if sh.type == 1:            # SHT_PROGBITS
                if not sh.flags & 1:        # !SHF_WRITE    ... .text
                    symtype = 0x0201
                else:                       #               ... .data
                    symtype = 0x0202
            elif sh.type == 8:          # SHT_NOBITS        ... .bss
                symtype = 0x0203

            if symtype:
                symtbl += pack(">HL", symtype, sym.value - baseaddr)
                symtbl += sym.name.encode() + \
                          b'\0' * (2 - (len(sym.name.encode()) & 1))

    return (X68kHeader(baseaddr, eh.entry,
                       len(contents[0]), len(contents[1]), len(contents[2]), 0, len(symtbl)),
            contents[0] + contents[1], symtbl)

# Generate X68k relocation data

def genx68krel(header, diff, body1, body2):
    body = bytearray(body1)
    reldata = b''
    prevoffset = 0

    skip = False
    for i in range(0, len(body1) - 3, 2):
        if skip:
            skip = False
            continue
        (w1,) = unpack(">L", body1[i:i + 4])
        (w2,) = unpack(">L", body2[i:i + 4])
        if w1 != w2:
            if w2 - w1 != diff:
                assert (w1 >> 16) == (w2 >> 16);
                continue
            body[i:i + 4] = pack(">L", w1 - header.base)
            offdiff = i - prevoffset
            prevoffset = i
            if offdiff < 0x10000:
                reldata += pack(">H", offdiff)
            else:
                reldata += pack(">HL", 1, offdiff)
            skip = True

    header.entry -= header.base
    header.base = 0
    header.relsz = len(reldata)

    return (header, body + reldata)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="ELF to X68k executable converter")
    parser.add_argument('file1', help='Input ELF file')
    parser.add_argument('file2', help='Input ELF file 2', nargs='?')
    parser.add_argument('-o', '--output', help='Output X68k exec file')
    parser.add_argument('-s', '--strip', help='Strip symbol table', action='store_true')
    args = parser.parse_args()

    if args.output:
        outfile = args.output
    else:
        outfile = args.file1 + ".x"

    with open(args.file1, 'rb') as f:
        (header1, body1, sym1) = elf2x68k(f)

    if args.file2:
        with open(args.file2, 'rb') as f:
            (header2, body2, sym2) = elf2x68k(f)
        (header, body) = genx68krel(header1, header2.base - header1.base, body1, body2)
    else:
        (header, body) = (header1, body1)

    if args.strip:
        sym1 = b''
        header.symsz = 0

    with open(outfile, 'wb') as f:
        f.write(header.encode() + body + sym1)
