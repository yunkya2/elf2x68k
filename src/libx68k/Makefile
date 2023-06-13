TARGET = libx68k.a libx68knodos.a

include Common.mk

# object files needed
OBJS += chown.o close.o creat.o execve.o fork.o fstat.o \
	getpid.o gettod.o isatty.o kill.o link.o lseek.o open.o \
	read.o readlink.o rename.o sbrk.o stat.o symlink.o times.o unlink.o \
	wait.o write.o _exit.o system.o \
	chdir.o mkdir.o rmdir.o
OBJS += crt1.o _sflags.o fds.o _doserror.o

OBJS_NODOS += write-nodos.o _nodosfnc.o

CRT0OBJS += crt0.o crt0nodos.o

all: $(TARGET) $(CRT0OBJS) libiocs.a libdos.a

libiocs.a:
	make -C libiocs all

libdos.a:
	make -C libdos all

libx68k.a: $(OBJS)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

libx68knodos.a: $(OBJS_NODOS)
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
