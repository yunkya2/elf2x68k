RELPATH = .
include $(RELPATH)/Common.mk

TARGET = $(LIBDIR)/libx68k.a $(LIBDIR)/libx68knodos.a
TARGET += $(LIBDIR)/libx68kiocs.a
TARGET += $(LIBDIR)/libx68kdos.a
TARGET += $(LIBDIR)/libsocket.a
TARGET += $(LIBDIR)/libpthread.a

INC += -I$(INCLUDEDIR) -I.

# object files needed
OBJS += chown.o close.o creat.o execve.o fcntl.o fork.o fstat.o \
	getpid.o gettod.o isatty.o kill.o link.o lseek.o open.o \
	read.o readlink.o rename.o sbrk.o stat.o symlink.o times.o unlink.o \
	wait.o write.o _exit.o system.o \
	chdir.o mkdir.o rmdir.o getcwd.o getentropy.o \
	opendir.o readdir.o closedir.o telldir.o seekdir.o \
	sleep.o poll.o dup.o dup2.o
OBJS += crt1.o crt1hupair.o _sflags.o fds.o _doserror.o _at_exit.o _dosinit.o
OBJS += _stacksize.o _heapsize.o _crt0vars.o _crt0vars1.o
OBJS := $(addprefix $(O)/,$(OBJS))

OBJS_NODOS += write-nodos.o sbrk-nodos.o _nodosfnc.o
OBJS_NODOS += _stacksize.o _heapsize.o _crt0vars-nodos.o
OBJS_NODOS := $(addprefix $(O)/,$(OBJS_NODOS))

CRT0OBJS = $(addprefix $(O)/,crt0.o crt0nodos.o crt0hupair.o)
CRT0TARGETS = $(addprefix $(LIBDIR)/x68k,crt0.o crt0nodos.o crt0hupair.o)
HEADERS = $(patsubst sys/%,$(INCLUDEDIR)/sys/%,$(wildcard sys/*.h))

all: install

install: $(TARGET) $(CRT0OBJS) $(CRT0TARGETS) $(HEADERS)

$(O) $(LIBDIR) $(INCLUDEDIR)/sys:
	@mkdir -p $@

$(LIBDIR)/libx68kiocs.a:
	$(MAKE) -C libiocs install

$(LIBDIR)/libx68kdos.a:
	$(MAKE) -C libdos install

$(LIBDIR)/libsocket.a:
	$(MAKE) -C libsocket install

$(LIBDIR)/libpthread.a:
	$(MAKE) -C libpthread install

$(LIBDIR)/libx68k.a: $(OBJS) | $(LIBDIR)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

$(LIBDIR)/libx68knodos.a: $(OBJS_NODOS) | $(LIBDIR)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

$(O)/%.o: %.c $(LIBDIR)/libx68kiocs.a $(LIBDIR)/libx68kdos.a | $(O)
	$(CC) $(CFLAGS) -o $@ -c $<

$(O)/%.o: %.S | $(O)
	$(AS) $(ASFLAGS) -o $@ -c $<

$(O)/%hupair.o: %.c | $(O)
	$(CC) $(CFLAGS) -o $@ -DSUPPORT_HUPAIR -c $<

$(O)/%hupair.o: %.S | $(O)
	$(AS) $(ASFLAGS) -o $@ -DSUPPORT_HUPAIR -c $<

$(LIBDIR)/x68kcrt%.o: $(O)/crt%.o | $(LIBDIR)
	cp -p $< $@

$(INCLUDEDIR)/sys/%.h: sys/%.h | $(INCLUDEDIR)/sys
	cp -p $< $@

.SECONDARY: $(CRT0OBJS)

clean:
	$(MAKE) -C libiocs allclean
	$(MAKE) -C libdos allclean
	$(MAKE) -C libsocket clean
	$(MAKE) -C libpthread clean
	-rm -rf $(O) $(LIBDIR) $(INCLUDEDIR)

.PHONY: all install clean
