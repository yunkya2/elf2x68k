TARGET = hellosys.sys

CROSS = m68k-elf-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)gcc
ELF2X68K = ../elf2x68k.py

CFLAGS = -m68000
LDFLAGS = -Ttext=0x6800 -s -specs=x68knodos.specs
LIBS =

all: $(TARGET)

$(TARGET): hellosys.o
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o *.elf* $(TARGET)
