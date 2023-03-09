CROSS = m68k-xelf-
CC = $(CROSS)gcc
AS = $(CROSS)gcc
LD = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -m68000 -I.
ASFLAGS = -m68000 -I.
