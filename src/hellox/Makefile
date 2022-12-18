TARGET = hellox.x

ARCH = m68k-linux-gnu-
CC = $(ARCH)gcc
AS = $(ARCH)as
LD = $(ARCH)gcc
ELF2X68K = ../elf2x68k.py

CFLAGS = -m68000
LDFLAGS1 = -Wl,-Ttext=0x6800 -Wl,-z,max-page-size=2 -nostdlib -static
LDFLAGS2 = -Wl,-Ttext=0x7800 -Wl,-z,max-page-size=2 -nostdlib -static

all: $(TARGET)

$(TARGET): $(TARGET:.x=.elf1) $(TARGET:.x=.elf2)
	$(ELF2X68K) -o $@ $^

$(TARGET:.x=.elf1): hellox.o
	$(LD) $(LDFLAGS1) -o $@ $<

$(TARGET:.x=.elf2): hellox.o
	$(LD) $(LDFLAGS2) -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c $^

clean:
	-rm -f *.o *.elf* $(TARGET)
