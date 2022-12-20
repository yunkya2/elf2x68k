TARGET = hellostdc.x

ARCH = m68k-elf-
CC = $(ARCH)gcc
AS = $(ARCH)as
LD = $(ARCH)gcc
ELF2X68K = ../elf2x68k.py

CFLAGS = -m68000
LDFLAGS1 = -Wl,-Ttext=0x6800 -Wl,-z,max-page-size=2 -static -Tx68k.ld -specs=./x68k.specs
LDFLAGS2 = -Wl,-Ttext=0x7800 -Wl,-z,max-page-size=2 -static -Tx68k.ld -specs=./x68k.specs

all: $(TARGET)

$(TARGET): $(TARGET:.x=.elf1) $(TARGET:.x=.elf2)
	$(ELF2X68K) -o $@ $^

$(TARGET:.x=.elf1): hellostdc.o
	$(LD) $(LDFLAGS1) -o $@ $^

$(TARGET:.x=.elf2): hellostdc.o
	$(LD) $(LDFLAGS2) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o *.elf* $(TARGET) testfile
