TARGET = hellosys.sys

CROSS = m68k-elf-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)gcc
ELF2X68K = ../elf2x68k.py

CFLAGS = -m68000
LDFLAGS = -nostdlib -static -Ttext=0x6800 -s

all: $(TARGET)

$(TARGET): hellosys.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o *.elf* $(TARGET)
