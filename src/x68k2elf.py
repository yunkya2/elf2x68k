#!/usr/bin/env python3
import sys
import os
import subprocess
import tempfile
import argparse
from struct import pack, unpack, calcsize

verbose = 0
keeplu = False

##############################################################################

# section type and flags, import from sys/elf_common.h
SHF_WRITE = 0x1
SHF_ALLOC = 0x2
SHF_EXECINSTR = 0x4
SHF_MERGE = 0x10
SHF_STRINGS = 0x20
SHF_INFO_LINK = 0x40

SHT_NULL = 0
SHT_PROGBITS = 1
SHT_SYMTAB = 2
SHT_STRTAB = 3
SHT_RELA = 4
SHT_HASH = 5
SHT_DYNAMIC = 6
SHT_NOTE = 7
SHT_NOBITS = 8
SHT_REL = 9

SHN_UNDEF = 0
SHN_ABS = 0xfff1
SHN_COMMON = 0xfff2

STB_LOCAL = 0
STB_GLOBAL = 1
STB_WEAK = 2

STT_NOTYPE = 0
STT_OBJECT = 1
STT_FUNC = 2
STT_SECTION = 3
STT_FILE = 4
STT_COMMON = 5
STT_TLS = 6
STT_NUM = 7

R_68K_NONE = 0
R_68K_32 = 1
R_68K_16 = 2
R_68K_8 = 3
R_68K_PC32 = 4
R_68K_PC16 = 5
R_68K_PC8 = 6

class ElfIdent:
    def __init__(self):
        data = b'\x7fELF\1\1\1' + b'\0' * 8
        self.cls, self.data, self.version, self.osabi, self.abiversion = unpack("5b", data[4:9])

    def encode(self):
        return b'\x7fELF' + \
            pack("5b", self.cls, self.data, self.version, self.osabi, self.abiversion) \
            + b'\0' * 7

class ElfHeader:
    def __init__(self, e):
        self.ident = ElfIdent()
        h = [0] * 13
        h[0] = 1
        h[7] = 16 + calcsize(self.parsestr())

        self.type = h[0]
        self.machine = h[1]
        self.version = h[2]
        self.entry = h[3]
        self.phoff = h[4]
        self.shoff = h[5]
        self.flags = h[6]
        self.ehsize = h[7]
        self.phentsize = h[8]
        self.phnum = h[9]
        self.shentsize = h[10]
        self.shnum = h[11]
        self.shstrndx = h[12]

    def parsestr(self):
        return ">2H5L6H"

    def encode(self, e):
        return self.ident.encode() + pack(self.parsestr(),
            self.type, self.machine, self.version, self.entry,
            self.phoff, self.shoff, self.flags, self.ehsize,
            self.phentsize, self.phnum, self.shentsize, self.shnum,
            self.shstrndx)

class SectionHeader:
    def __init__(self, e, name=None, type=None):
        h = [0] * 10
        self.nameidx = h[0]
        self.type = h[1]
        self.flags = h[2]
        self.addr = h[3]
        self.offset = h[4]
        self.size = h[5]
        self.link = h[6]
        self.info = h[7]
        self.addralign = h[8]
        self.entsize = h[9]
        self.name = ""
        self.relidx = None

        self.pad = 0
        self.contents = b''
        if name:
            self.name = name
            self.nameidx = e.add_shstrtab(name)
        if type:
            self.type = type

    @classmethod
    def parsestr(cls, e):
        return ">10L"

    def encode(self, e):
        return pack(self.parsestr(e),
            self.nameidx, self.type, self.flags, self.addr, self.offset,
            self.size, self.link, self.info, self.addralign, self.entsize)

class SectionHeaderList(list):
    def __init__(self, e):
        super().__init__(self)
        self.append(SectionHeader(e))

    def encode(self, e):
        d = b''
        for sh in self:
            d += sh.encode(e)
        return d

class Symbol:
    def __init__(self, e, name=None, type=None):
        s = [0] * 6
        self.nameidx = s[0]
        self.value = s[1]
        self.size = s[2]
        self.info = s[3]
        self.bind = self.info >> 4
        self.type = self.info & 0xf
        self.other = s[4]
        self.shndx = s[5]

        if name == None:
            strtab = e.strtab.contents
            self.name = strtab[self.nameidx:strtab.index(b'\0',self.nameidx)].decode()
        else:
            self.name = name
            self.nameidx = e.add_strtab(name)
        if type != None:
            self.type = type

    @classmethod
    def parsestr(cls, e):
        return ">3L2bH"

    def encode(self, e):
        self.info = (self.bind << 4) + (self.type & 0xf)
        return pack(self.parsestr(e),
            self.nameidx, self.value, self.size, self.info,
            self.other, self.shndx)

class SymbolList(list):
    def __init__(self, e):
        super().__init__(self)
        self.append(Symbol(e))

    def encode(self, e):
        d = b''
        for s in self:
            d += s.encode(e)
        return d

class Rela:
    def __init__(self, e):
        s = [0] * 3
        self.offset = s[0]
        self.info = s[1]
        self.addend = s[2]
        self.sym = s[1] >> 8
        self.type = s[1] & 0xff
        self.name = e.symlist[self.sym].name

    @classmethod
    def parsestr(cls, e):
        return ">2Ll"

    def encode(self, e):
        self.info = (self.sym << 8) + (self.type & 0xff)
        return pack(self.parsestr(e), self.offset, self.info, self.addend)

class RelList(list):
    def __init__(self, e, sh):
        super().__init__(self)
        self.sh = sh

    def encode(self, e):
        d = b''
        for r in self:
            d += r.encode(e)
        return d

class elf_parser:
    def __init__(self):
        self.elf_header = ElfHeader(self)
        self.wordsize = 4
        self.phlist = []
        self.shlist = SectionHeaderList(self)

        self.relinfo = []

        self.shstrtab = SectionHeader(self, type=SHT_STRTAB)
        self.shstrtab.addralign = 1
        self.shstrtab.contents = b'\0'

        self.symtab = SectionHeader(self, type=SHT_SYMTAB, name='.symtab')
        self.symtab.addralign = self.wordsize

        self.strtab = SectionHeader(self, type=SHT_STRTAB, name='.strtab')
        self.strtab.addralign = 1
        self.strtab.contents = b'\0'

        self.shstrtab.nameidx = self.add_shstrtab('.shstrtab')

        self.symlist = SymbolList(self)

    def add_strtab(self, symbol):
        pos = len(self.strtab.contents)
        self.strtab.contents += symbol.encode() + b'\0'
        return pos;

    def add_shstrtab(self, shname):
        pos = len(self.shstrtab.contents)
        self.shstrtab.contents += shname.encode() + b'\0'
        return pos;


    def encode(self):
        def posalign(pos, align):
            if pos % align != 0:
                return align - (pos % align)
            return 0

        if self.symtab and (not self.symtab in self.shlist):
            self.shlist.append(self.symtab)
        if self.strtab and (not self.strtab in self.shlist):
            self.symtab.link = len(self.shlist)
            self.shlist.append(self.strtab)
        if self.shstrtab and (not self.shstrtab in self.shlist):
            self.elf_header.shstrndx = len(self.shlist)
            self.shlist.append(self.shstrtab)

        # Update contents
        if self.symtab:
            self.symtab.contents = self.symlist.encode(self)
            self.symtab.entsize = calcsize(Symbol.parsestr(self))
            self.symtab.info = 0
            for sy in self.symlist:
                if sy.bind == STB_LOCAL:
                    self.symtab.info += 1

        for r in self.relinfo:
            r.sh.contents = r.encode(self)
            r.sh.entsize = calcsize(Rela.parsestr(self))
            r.sh.link = self.shlist.index(self.symtab)

        # Update offsets
        pos = len(self.elf_header.encode(self))
        pos += self.elf_header.phentsize * self.elf_header.phnum

        for sh in self.shlist:
            if sh.type != SHT_NULL:
                sh.offset = pos + sh.pad
            if sh.type != SHT_NOBITS:
                sh.size = len(sh.contents)
            pos += sh.pad + len(sh.contents)

        pos += posalign(pos, self.wordsize)
        self.elf_header.shentsize = calcsize(SectionHeader.parsestr(self))
        self.elf_header.shoff = pos
        self.elf_header.shnum = len(self.shlist)

        # Reconstruct ELF file
        data = self.elf_header.encode(self)
        if self.phlist:
            data += self.phlist.encode(self)
        for sh in self.shlist:
            data += b'\0' * sh.pad + sh.contents
        data += b'\0' * (self.elf_header.shoff - len(data))
        if self.shlist:
            data += self.shlist.encode(self)
        return data

##############################################################################

def getword(f):
    data = f.read(2)
    if not data or len(data) != 2:
        return None
    (r,) = unpack('>H', data)
    return r

def getlong(f):
    data = f.read(4)
    if not data or len(data) != 4:
        return None
    (r,) = unpack('>L', data)
    return r

def getstr(f):
    s = b''
    while True:
        data = f.read(2)
        if not data or len(data) != 2:
            return None
        (c1, c2) = unpack('2c', data)
        if c1 == b'\0':
            return s.decode() 
        s += c1
        if c2 == b'\0':
            return s.decode()
        s += c2

def getsymstr(f):
    s = getstr(f)
    if s and not keeplu:
        if s[0] == '_':
            return s[1:]
    return s

def getdata(f, l):
    d = b''
    while l > 0:
        data = f.read(2)
        if not data or len(data) != 2:
            return None
        if l == 1:
            d += data[0:1]
            break
        d += data
        l -= 2
    return d

def getfdate(date):
    return f'{1980 + (date >> 25)}-{(date >> 21) & 0xf:02d}-{(date >> 16) & 0x1f:02d} ' \
        + f'{(date >> 11) & 0x1f:02d}:{(date >> 5) & 0x3f:02d}:{(date & 0x1f) << 1:02d}'

def getname(name):
    return name[0:name.find(b'\0')].decode()

def convlog(msg):
    if verbose:
        print(msg, end='')

def mkarchive(fn, files):
    if fn:
        if os.path.exists(fn):
            os.remove(fn)
        cmd = ['ar', 'rcs', fn] + files
        subprocess.run(cmd)

##############################################################################
# Convert X68k object file to ELF object file

def objfile(f, fn):
    e = elf_parser()
    e.elf_header.ident.data = 2     # big endian
    e.elf_header.type = 1           # Relocatable
    e.elf_header.machine = 4        # M68k
    e.elf_header.version = 1        # version

    section = 1         # current section
    sectlist = {}       # SectionHeader list
    sectnum = {}        # X68k section -> ELF section
    sectsym = {}        # X68k section -> ELF symbol number
    symnum = {}         # X68k label number -> ELF symbol number
    rellist = {}        # Rela list
    commlabel = 0       # common label number
    exprstack = []      # expression stack

    while True:
        c = f.read(2)
        if not c:
            return False
        (cmd,) = unpack('>H', c)
        cmdh = cmd >> 8
        cmdl = cmd & 0xff

        if section in sectlist:
            convlog(f'{section:x}:{len(sectlist[section].contents):04x} ')
        else:
            convlog(f'{section:x}:{0:04x} ')
        convlog(f'{cmd:04x}  ')

        if cmd == 0x0000:
            convlog(f'END\n')
            if fn:
                with open(fn, 'wb') as f:
                    f.write(e.encode())
            return True

        elif cmdh == 0x10:
            data = getdata(f, cmdl + 1)
            convlog(f'DATA: {data}\n')
            sectlist[section].contents += data

        elif cmdh == 0x20:
            val = getlong(f)
            section = cmdl
            convlog(f'SECTION: sec=0x{cmdl:02x}\n')

        elif cmdh == 0x30:
            size = getlong(f)
            sectlist[section].contents += b'\0' * size
            convlog(f'SPACE: size={size}\n')

        elif (cmdh & 0xf0) == 0x40 or (cmdh & 0xf0) == 0x50:
            if cmdh & 3 == 0:
                sectlist[section].contents += b'\0'

            ra = Rela(e)
            ra.offset = len(sectlist[section].contents)
            ra.type = [R_68K_8, R_68K_16, R_68K_32, R_68K_8][cmdh & 3]
            size = ["BYTE2", "WORD", "LONG", "BYTE"][cmdh & 3]
            slen = [1, 2, 4, 1][cmdh & 3]

            addend = 0
            if cmdl >= 0xfc:
                label = getword(f)
                if (cmdh & 0xf0) == 0x50:
                    addend = getlong(f)
                ra.sym = symnum[label]
                ra.addend = addend
                convlog(f'REF{size}: sec=0x{cmdl:02x} label={label} name={e.symlist[ra.sym].name}')
            else:
                offst = getlong(f)
                if (cmdh & 0xf0) == 0x50:
                    addend = getlong(f)
                ra.sym = sectsym[cmdl]
                ra.addend = offst + addend
                convlog(f'ADR{size}: sec=0x{cmdl:02x} offst=0x{offst:08x}')
            if (cmdh & 0xf0) == 0x50:
                convlog(f' addend=0x{addend:08x}\n')
            else:
                convlog(f'\n')

            sectlist[section].contents += b'\0' * slen
            rellist[section].append(ra)

        elif (cmdh & 0xf0) == 0x60:
            ra = Rela(e)
            ra.offset = len(sectlist[section].contents)
            ra.type = [0, R_68K_PC16, R_68K_PC32, R_68K_PC8][cmdh & 3]
            size = ["", "WORD", "LONG", "BYTE"][cmdh & 3]
            slen = [1, 2, 4, 1][cmdh & 3]

            offst = getlong(f)
            label = getword(f)
            ra.sym = symnum[label]
            ra.addend = len(sectlist[section].contents) - offst

            convlog(f'REL{size}: sec=0x{cmdl:02x} offst=0x{offst:08x} label={label} name={e.symlist[ra.sym].name} addend={ra.addend}\n')

            sectlist[section].contents += b'\0' * slen
            rellist[section].append(ra)

        elif cmdh == 0x80:
            if cmdl >= 0xfc:
                arg = getword(f)
                convlog(f'PUSHREF: sec=0x{cmdl:02x} label={arg} name={e.symlist[symnum[arg]].name}\n')
            else:
                arg = getlong(f)
                convlog(f'PUSHADR: sec=0x{cmdl:02x} offst=0x{arg:08x}\n')
            # push into expression stack
            # (section, label, addend, isrelative)
            exprstack.append((cmdl, arg, 0, False))

        elif (cmdh & 0xf0) == 0x90:
            stacktop = exprstack[len(exprstack) - 1]
            exprstack = exprstack[:len(exprstack) - 1]
            ra = Rela(e)
            ra.offset = len(sectlist[section].contents)
            size = ["BYTE", "WORD", "LONG", "BYTE"][cmdh & 3]
            slen = [1, 2, 4, 1][cmdh & 3]

            if stacktop[0] == 0:                # imm
                sectlist[section].contents += pack(['B','H','L','B'][cmdh & 3], stacktop[1])
            else:
                if stacktop[3]:                 # relative
                    ra.type = [R_68K_PC8, R_68K_PC16, R_68K_PC32, R_68K_PC8][cmdh & 3]
                    rel = 'REL'
                else:                           # absolute
                    ra.type = [R_68K_8, R_68K_16, R_68K_32, R_68K_8][cmdh & 3]
                    rel = ''

                if stacktop[0] >= 0xfc:
                    label = stacktop[1]
                    addend = stacktop[2]
                    ra.sym = symnum[label]
                    ra.addend = addend
                    convlog(f'POPREF{rel}{size}: label={label} name={e.symlist[ra.sym].name} addend={ra.addend}\n')
                elif stacktop[0] > 0:
                    sect = stacktop[0]
                    offst = stacktop[1]
                    addend = stacktop[2]
                    ra.sym = sectsym[sect]
                    ra.addend = offst + addend
                    convlog(f'POPADR{rel}{size}: sec=0x{sect:02x} offst=0x{offst:08x} addend={ra.addend}\n')

                sectlist[section].contents += b'\0' * slen
                rellist[section].append(ra)

        elif cmdh == 0xa0:
            if cmdl < 0x09:
                stacktop = exprstack[len(exprstack) - 1]
                exprstack = exprstack[:len(exprstack) - 1]
                assert(stacktop[0] == 0)                    # op imm
                if cmdl == 0x01:
                    r = -stacktop[1]
                    op = 'NEG'
                elif cmdl == 0x02:
                    r = stacktop[1]
                    op = 'POS'
                elif cmdl == 0x03:
                    r = stacktop[1] ^ 0xffffffff
                    op = 'NOT'
                elif cmdl == 0x04:
                    r = (stacktop[1] & 0xff00) >> 8
                    op = 'HIGH'
                elif cmdl == 0x05:
                    r = stacktop[1] & 0xff
                    op = 'LOW'
                elif cmdl == 0x06:
                    r = stacktop[1] >> 16
                    op = 'HIGHW'
                elif cmdl == 0x07:
                    r = stacktop[1] & 0xffff
                    op = 'LOWW'
                else:
                    assert(0)
                exprstack.append((0, r, 0, False))
            else:
                s1 = exprstack[len(exprstack) - 2]
                s2 = exprstack[len(exprstack) - 1]
                exprstack = exprstack[:len(exprstack) - 2]
                if cmdl == 0x0f:
                    op = 'SUB'
                    if s1[0] == 0 and s2[0] == 0:           # imm - imm
                        exprstack.append((0, s[1] - s[2], 0, False))
                    elif s2[0] == 0:                        # label - imm
                        exprstack.append((s1[0], s1[1], s1[2] - s2[1], False))
                    elif s1[0] == 0:                        # imm - label .. error
                        assert(0)
                    else:                                   # label - label
                        assert(s2[0] == section)
                        exprstack.append((s1[0], s1[1], s1[2] - (s2[1] - len(sectlist[section].contents)), True))
                elif cmdl == 0x10:
                    op = 'ADD'
                    if s1[0] == 0 and s2[0] == 0:           # imm + imm
                        exprstack.append((0, s[1] + s[2], 0, False))
                    elif s1[0] == 0:                        # imm + label
                        exprstack.append((s2[0], s2[1], s2[2] + s1[1], False))
                    elif s2[0] == 0:                        # label + imm
                        exprstack.append((s1[0], s1[1], s1[2] + s2[1], False))
                    else:
                        assert(0)
                else:
                    assert(s1[0] == 0 and s2[0] == 0)       # imm op imm
                    if cmdl == 0x09:
                        r = s1[1] * s2[1]
                        op = 'MUL'
                    elif cmdl == 0x0a:
                        r = s1[1] // s2[1]
                        op = 'DIV'
                    elif cmdl == 0x0b:
                        r = s1[1] % s2[1]
                        op = 'MOD'
                    elif cmdl == 0x0c:
                        r = s1[1] >> s2[1]
                        op = 'SHR'
                    elif cmdl == 0x0d:
                        r = s1[1] << s2[1]
                        op = 'SHL'
                    elif cmdl == 0x0e:
                        r = (s1[1] >> s2[1]) | (s1[1] & 0x80000000)
                        op = 'ASR'
                    elif cmdl == 0x11:
                        r = 0xffffffff if s1[1] == s2[1] else 0
                        op = 'EQ'
                    elif cmdl == 0x12:
                        r = 0xffffffff if s1[1] != s2[1] else 0
                        op = 'NE'
                    elif cmdl == 0x13:
                        r = 0xffffffff if s1[1] < s2[1] else 0
                        op = 'LT'
                    elif cmdl == 0x14:
                        r = 0xffffffff if s1[1] <= s2[1] else 0
                        op = 'LE'
                    elif cmdl == 0x15:
                        r = 0xffffffff if s1[1] > s2[1] else 0
                        op = 'GT'
                    elif cmdl == 0x16:
                        r = 0xffffffff if s1[1] >= s2[1] else 0
                        op = 'GE'
                    elif cmdl == 0x1b:
                        r = s1[1] & s2[1]
                        op = 'AND'
                    elif cmdl == 0x1c:
                        r = s1[1] ^ s2[1]
                        op = 'XOR'
                    elif cmdl == 0x1d:
                        r = s1[1] | s2[1]
                        op = 'OR'
                    else:
                        # convert to signed integer
                        a1 = unpack('i', pack('I', s1[1]))[0]
                        a2 = unpack('i', pack('I', s2[1]))[0]
                        if cmdl == 0x17:
                            r = 0xffffffff if a1 < a2 else 0
                            op = 'SLT'
                        elif cmdl == 0x18:
                            r = 0xffffffff if a1 <= a2 else 0
                            op = 'SLE'
                        elif cmdl == 0x19:
                            r = 0xffffffff if a1 > a2 else 0
                            op = 'SGT'
                        elif cmdl == 0x1a:
                            r = 0xffffffff if a1 >= a2 else 0
                            op = 'SGE'
                        else:
                            assert(0)

                    exprstack.append((0, r, 0, False))
            s = exprstack[len(exprstack) - 1]
            convlog(f'OP{op}: sec=0x{s[0]:02x} val=0x{s[1]:08x} addend={s[2]} relative={s[3]}\n')

        elif cmdh == 0xb2 or cmdh == 0xb0:
            val = getlong(f)
            name = getsymstr(f)
            s = Symbol(e, name=name, type=STT_NOTYPE)
            s.bind = STB_GLOBAL

            if cmdl == 0:                   # ABS
                s.shndx = SHN_ABS
                s.value = val
                convlog(f'SYMBOL: sec=0x{cmdl:02x} val=0x{val:08x} name={name}\n')
            elif cmdl < 0xfc:               # section
                s.shndx = sectnum[cmdl]
                s.value = val
                convlog(f'SYMBOL: sec=0x{cmdl:02x} offset=0x{val:08x} name={name}\n')
            elif cmdl < 0xff:               # comm
                s.shndx = SHN_COMMON
                s.type = STT_OBJECT
                s.value = val
                s.size = val
                commlabel += 1
                symnum[commlabel] = len(e.symlist)
                convlog(f'SYMBOL: sec=0x{cmdl:02x} label={commlabel} size={val} name={name}\n')
            else:                           # xref
                s.shndx = SHN_UNDEF
                symnum[val] = len(e.symlist)
                commlabel += 1
                convlog(f'SYMBOL: sec=0x{cmdl:02x} label={val} name={name}\n')

            e.symlist.append(s)

        elif cmdh == 0xc0:
            size = getlong(f)
            fname = getstr(f)
            convlog(f'SECDEF: sec=0x{cmdl:02x} size={size} name={fname}\n')

            s = SectionHeader(e, name='.'+fname, type=SHT_PROGBITS)
            s.size = size
            s.addralign = 2
            if cmdl == 1:           # text
                s.type = SHT_PROGBITS
                s.flags = SHF_ALLOC | SHF_EXECINSTR
            elif cmdl == 2:         # data
                s.type = SHT_PROGBITS
                s.flags = SHF_ALLOC | SHF_WRITE
            elif cmdl == 3 or cmdl == 4:          # bss or stack
                s.type = SHT_NOBITS
                s.flags = SHF_ALLOC | SHF_WRITE

            sectnum[cmdl] = len(e.shlist)
            e.shlist.append(s)
            sectlist[cmdl] = s

            sectsym[cmdl] = len(e.symlist)
            s = Symbol(e, name=fname, type=STT_SECTION)
            s.shndx = sectnum[cmdl]
            e.symlist.append(s)

            if cmdl != 3 and cmdl != 4:
                rs = SectionHeader(e, name='.rela.'+fname, type=SHT_RELA)
                rs.info = sectnum[cmdl]
                rs.flags = SHF_INFO_LINK
                e.shlist.append(rs)

                r = RelList(e, rs)
                e.relinfo.append(r)
                rellist[cmdl] = r

        elif cmdh == 0xd0:
            size = getlong(f)
            fname = getstr(f)
            convlog(f'FILE: size={size} name={fname}\n')

            s = Symbol(e, name=fname, type=STT_FILE)
            s.shndx = SHN_ABS
            e.symlist.append(s)

        elif cmdh == 0xe0:
            sect = getword(f)
            addr = getlong(f)
            convlog(f'EXECADDR: sec=0x{sect:02x} addr=0x{addr:08x}\n')

        else:
            assert(0)
            return False

##############################################################################
# Convert X68k archive file (*.a) to ELF object file archive

def arfile(f, fn):
    with tempfile.TemporaryDirectory() as tmpdir:
        f.seek(6)
        files = []
        while True:
            name = getname(f.read(24))
            if not name:
                break
            size = getlong(f)
            date = getlong(f)
            date = (date >> 16) | ((date & 0xffff) << 16)
            pos = f.tell()
            convlog(f'======== {name} pos={pos} size={size} {getfdate(date)}\n')

            nm = tmpdir + '/' + name
            if not objfile(f, nm):
                break
            files.append(nm)
            f.seek(pos + size)

        mkarchive(fn, files)

##############################################################################
# Convert X68k library file (*.l) to ELF object file archive

def libfile(f, fn):
    with tempfile.TemporaryDirectory() as tmpdir:
        f.seek(2)
        name = getname(f.read(24))
        size = getlong(f)
        f.read(2)
        fofst = getlong(f)
        fsize = getlong(f)
        sofst = getlong(f)
        ssize = getlong(f)
        nofst = getlong(f)
        nsize = getlong(f)

        convlog(f'######## {name} size={size}\n')

        f.seek(fofst)
        files = []
        while fsize > 0:
            name = getname(f.read(24))
            index = getlong(f)
            oofst = getlong(f)
            osize = getlong(f)
            date = getlong(f)
            f.read(8)
            fsize -= 0x30
            convlog(f'======== {name} pos={oofst} size={osize} {getfdate(date)}\n')
            pos = f.tell()
            f.seek(oofst)

            nm = tmpdir + '/' + name
            if not objfile(f, nm):
                break
            files.append(nm)

            f.seek(pos)

        mkarchive(fn, files)

##############################################################################

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="X68k object/library to ELF converter")
    parser.add_argument('infile', help='Input object/library file')
    parser.add_argument('outfile', help='Output ELF file', nargs='?')
    parser.add_argument('-k', '--keep', help='Keep leading underscore', action='store_true')
    parser.add_argument('-v', '--verbose', help='Verbose output', action='count', default=0)
    args = parser.parse_args()

    verbose = args.verbose
    keeplu = args.keep

    with open(args.infile, 'rb') as f:
        # Detect file type
        h = f.read(6)
        f.seek(0)

        if h[0:2] == b'\xd0\x00':               # *.o
            objfile(f, args.outfile)
        elif h == b'\xd1\x00\x00\x00\x00\x02':  # *.a
            arfile(f, args.outfile)
        elif h[0:2] == b'\x00\x68':             # *.l
            libfile(f, args.outfile)
        else:
            print(sys.argv[0] + ': ' + args.infile + ': Unrecognized file format')
            sys.exit(1)
