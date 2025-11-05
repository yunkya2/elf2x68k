CROSS = m68k-xelf-
CC = $(CROSS)gcc
AS = $(CROSS)gcc
LD = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -m68000 -I. -Os -fcall-used-d2 -fcall-used-a2 -fexec-charset=cp932
ASFLAGS = -m68000 -I.
