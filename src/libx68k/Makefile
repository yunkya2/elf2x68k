TARGET = libx68k.a

CROSS = m68k-elf-
CC = $(CROSS)gcc
AS = $(CROSS)gcc
LD = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -m68000 -I.
ASFLAGS = -m68000 -I.

# object files needed
OBJS += chown.o close.o errno.o execve.o fork.o fstat.o \
	getpid.o gettod.o isatty.o kill.o link.o lseek.o open.o \
	read.o readlink.o sbrk.o stat.o symlink.o times.o unlink.o \
	wait.o write.o _exit.o
OBJS += crt0.o crt1.o

all: $(TARGET) libiocs.a libdos.a

libiocs.a:
	make -C libiocs all

libdos.a:
	make -C libdos all

$(TARGET): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

%.o: %.c
	$(CC) $(CFLAGS) -c $<

%.o: %.S
	$(AS) $(ASFLAGS) -c $<

clean:
	make -C libiocs clean
	make -C libdos clean
	-rm -f *.o $(TARGET)
