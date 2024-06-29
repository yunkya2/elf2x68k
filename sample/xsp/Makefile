TARGET = xsp_010.x xsp_020.x xsp_030.x xsp_040.x xsp_050.x xsp_060.x
SRCS = $(TARGET:.x=.c)

CROSS = m68k-xelf-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)gcc

CFLAGS = -m68000 -O2
LDFLAGS = -lm -lbas -liocs -ldos

LIBS = lib/xsp2lib.o lib/pcm8afnc.o lib/pcg90.o

all: $(TARGET)

%.x: %.c
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS) $(LDFLAGS)

$(SRCS):
	./getxsp.sh

clean:
	-rm -f *.x *.x.elf

pristine:
	$(MAKE) clean
	-rm -rf lib data *.c

.PHONY: all clean pristine
