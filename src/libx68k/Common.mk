CROSS = m68k-xelf-
CC = $(CROSS)gcc
AS = $(CROSS)gcc
LD = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -m68000 $(INC)
CFLAGS +=  -Os -fcall-used-d2 -fcall-used-a2 -fexec-charset=cp932
CFLAGS += -D__IOCS_INLINE__ -D__DOS_INLINE__
#CFLAGS += -g
ASFLAGS = -m68000 $(INC)

O = build
LIBDIR = $(RELPATH)/../lib
INCLUDEDIR = $(RELPATH)/../include
