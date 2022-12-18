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

class X68kHeader:
    def __init__(self, base, entry, textsz, datasz, bsssz, relsz):
        (self.base, self.entry, self.textsz, self.datasz, self.bsssz, self.relsz) = \
            (base, entry, textsz, datasz, bsssz, relsz)

    def encode(self):
        return b'HU\0\0' + pack(">7L",
                                self.base, self.entry,
                                self.textsz, self.datasz, self.bsssz, self.relsz, 0) + \
                           b'\0' * 32

# Convert ELF to X68k execute file (fixed load address)

def elf2x68k(fh):
    # Read ELF header
    eh = ElfHeader(fh)

    # Read Program headers
    fh.seek(eh.phoff)
    phlist = []
    for i in range(eh.phnum):
        phlist.append(ProgramHeader(eh, fh))

    # Read Segment data
    baseaddr = 0
    textbody = b''
    databody = b''
    bsssize = 0
    for ph in phlist:
        if ph.type == 1:                # PT_LOAD
            if ph.flags & 1 == 1:                       # text
                if ph.offset == 0:      # skip ELF header
                    zheadsz = eh.ehsize + eh.phentsize * eh.phnum
                else:                                   
                    zheadsz = 0
                fh.seek(ph.offset + zheadsz)
                textbody = fh.read(ph.filesz - zheadsz)
                bsssize = ph.memsz - ph.filesz
                baseaddr = ph.vaddr + zheadsz
            elif (ph.flags & 2) and (ph.filesz > 0):    # data
                textbody += b'\0' * (ph.vaddr - (baseaddr + len(textbody)))
                fh.seek(ph.offset)
                databody = fh.read(ph.filesz)
                bsssize += ph.memsz - ph.filesz
            elif (ph.flags & 2) and (ph.filesz == 0):   # bss
                bsssize += ph.memsz

    return (X68kHeader(baseaddr, eh.entry, len(textbody), len(databody), bsssize, 0),
            textbody + databody)

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
            assert (w2 - w1) == diff
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
    args = parser.parse_args()

    if args.output:
        outfile = args.output
    else:
        outfile = args.file1 + ".x"

    with open(args.file1, 'rb') as f:
        (header1, body1) = elf2x68k(f)

    if args.file2:
        with open(args.file2, 'rb') as f:
            (header2, body2) = elf2x68k(f)
        (header, body) = genx68krel(header1, header2.base - header1.base, body1, body2)
    else:
        (header, body) = (header1, body1)

    with open(outfile, 'wb') as f:
        f.write(header.encode() + body)
