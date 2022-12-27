TARGET = hellostdc.x

CROSS = m68k-elf-
CC = $(CROSS)gcc
AS = $(CROSS)as
LD = $(CROSS)gcc

CFLAGS = -m68000
LDFLAGS = -specs=x68k.specs

all: $(TARGET)

$(TARGET): hellostdc.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o *.elf* $(TARGET) testfile
