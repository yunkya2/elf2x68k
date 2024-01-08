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

class Rela:
    def __init__(self, eh, fh):
        relparse = ">2Ll"
        data = fh.read(calcsize(relparse))
        (self.offset, self.info, self.addend) = unpack(relparse, data)
        self.sym = self.info >> 8
        self.type = self.info & 0xff

    def __repr__(self):
        return "0x%08x 0x%08x 0x%08x" % (self.offset, self.info, self.addend)

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

class X68kSymbol:
    def __init__(self, type, value, name):
        (self.type, self.value, self.name) = (type, value, name)

    def encode(self, base = 0):
        enname = self.name.encode()
        return pack(">HL", self.type, self.value + base) + \
               enname + b'\0' * (2 - (len(enname) & 1))

# Convert ELF to X68k execute file (fixed load address)

def elf2x68k(fh, xbase=0, strip=False):
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
    sh_rela = []
    fh.seek(eh.shoff)
    for i in range(eh.shnum):
        sh = SectionHeader(eh, fh)
        if sh.type == 2:                # SHT_SYMTAB
            sh_symtab = sh
        elif sh.type == 4:              # SHT_RELA
            sh_rela.append(sh)
        shlist.append(sh)

    # Read Relocation table
    rellist = []
    for sh in sh_rela:
        if shlist[sh.info].flags & 2:   # SHF_ALLOC
            fh.seek(sh.offset)
            while fh.tell() - sh.offset < sh.size:
                rel = Rela(eh, fh)
                rellist.append(rel)

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
    body = bytearray(contents[0] + contents[1])

    # Create relocation information for X68k
    reldata = b''
    prevoffset = 0
    for r in rellist:
        if symlist[r.sym].shndx !=0 and r.type < 4:
            assert r.type == 1          # R_68K_32
            off = r.offset - baseaddr
            val = unpack(">L",body[off:off + 4])[0] - baseaddr + xbase
            body[off:off + 4] = pack(">L", val)

            offdiff = off - prevoffset
            prevoffset = off
            if offdiff < 0x10000:
                reldata += pack(">H", offdiff)
            else:
                reldata += pack(">HL", 1, offdiff)

    # Create symbol table for X68k
    symtbl = b''
    if not strip:
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
                    symtbl += X68kSymbol(symtype, sym.value - baseaddr + xbase, sym.name).encode()

    return (X68kHeader(xbase, eh.entry - baseaddr + xbase,
                       len(contents[0]), len(contents[1]), len(contents[2]),
                       len(reldata), len(symtbl)).encode() + body + reldata + symtbl)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="ELF to X68k executable converter")
    parser.add_argument('file', help='Input ELF file')
    parser.add_argument('-o', '--output', help='Output X68k exec file')
    parser.add_argument('-b', '--base', help='Set base address', type=lambda x: int(x, 0))
    parser.add_argument('-s', '--strip', help='Strip symbol table', action='store_true')
    args = parser.parse_args()

    base = args.base        if args.base else 0
    outfile = args.output   if args.output else args.file + ".x"

    with open(args.file, 'rb') as fi:
        with open(outfile, 'wb') as fo:
            fo.write(elf2x68k(fi, base, args.strip))
