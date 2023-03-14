TARGET = hellosys.sys

CROSS = m68k-xelf-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)gcc

CFLAGS = -m68000 -O2
LDFLAGS = -Ttext=0x6800 -s -specs=x68knodos.specs

all: $(TARGET)

$(TARGET): hellosys.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o *.elf* $(TARGET)
