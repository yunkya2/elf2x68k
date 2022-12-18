TARGET = hellosys.sys

ARCH = m68k-linux-gnu-
CC = $(ARCH)gcc
AS = $(ARCH)as
LD = $(ARCH)gcc
ELF2X68K = ../elf2x68k.py

CFLAGS = -m68000
LDFLAGS = -Wl,-Ttext=0x6800 -Wl,-z,max-page-size=2 -nostdlib -static

all: $(TARGET)

$(TARGET): $(TARGET:.sys=.elf)
	$(ELF2X68K) -o $@ $^

$(TARGET:.sys=.elf): hellosys.o
	$(CC) $(LDFLAGS) -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c $^

clean:
	-rm -f *.o *.elf* $(TARGET)
