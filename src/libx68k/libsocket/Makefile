RELPATH = ..
include $(RELPATH)/Common.mk
TARGET = $(LIBDIR)/libsocket.a

vpath %.c ..

CFLAGS += -DLIBSOCKET
INC += -I$(INCLUDEDIR) -I. -I.. -Iinclude

TCPPACK_SOURCES = \
    search_ti_entry.c \
    gethostnamadr.c
TCPPACK_HEADERS = \
    network.h \
    tcpipdrv.h

LIB_SOURCES = \
    $(TCPPACK_SOURCES) \
    accept.c \
    bind.c \
    connect.c \
    listen.c \
    socket.c \
    recv.c \
    recvfrom.c \
    send.c \
    sendto.c \
    shutdown.c \
    getsockname.c \
    getpeername.c \
    close.c \
    read.c \
    write.c \
    fcntl.c \
    getsockopt.c \
    setsockopt.c \
    inet_ntoa.c \
    inet_aton.c \
    getnetnamadr.c \
    getservnamprt.c \
    getprotonamnum.c \
    getaddrinfo.c \
    poll.c \

OBJ = $(addprefix $(O)/,$(LIB_SOURCES:.c=.o))
HEADERS = $(patsubst include/%,$(INCLUDEDIR)/%,$(shell find include -type f))

all: $(TARGET) $(HEADERS)

$(O) $(LIBDIR):
	@mkdir -p $@

tcppack: TCPPACKB.LZH
	-rm -rf $@
	-mkdir $@
	(cd $@; unlha.py x ../$<)
	$(MAKE) patch

tcppack-copy: tcppack
	cat tcppack/include/network.h | tr -d \\r > network.h
	cat tcppack/include/tcpipdrv.h | tr -d \\r > tcpipdrv.h
	cat tcppack/src/libnetwork/search_ti_entry.c | iconv -f cp932 -t utf-8 | tr -d \\r > search_ti_entry.c
	cat tcppack/src/libnetwork/gethostnamadr.c | iconv -f cp932 -t utf-8 | tr -d \\r > gethostnamadr.c

patch: tcppack-copy
	patch -p4 < tcppack.patch

$(TCPPACK_SOURCES) $(TCPPACK_HEADERS): tcppack

update-patch: tcppack
	git checkout -B libpsocket-temp
	git add -f $(TCPPACK_SOURCES) network.h tcpipdrv.h
	git commit -m 'Update tcppack sources and headers'
	$(MAKE) tcppack-copy
	git add -f $(TCPPACK_SOURCES) network.h tcpipdrv.h
	git commit -m 'Original tcppack sources and headers'
	git revert --no-edit HEAD
	git show | sed -n '/^diff/,$$p' > tcppack.patch
	git switch -
	git branch -D libpsocket-temp
	$(MAKE) patch

$(TARGET): $(OBJ) | $(LIBDIR)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

$(O)/%.o: %.c $(TCPPACK_HEADERS) | $(O)
	$(CC) $(CFLAGS) -o $@ -c $<

$(HEADERS): $(INCLUDEDIR)/%: include/%
	@mkdir -p $(@D)
	cp -p $< $@

install: all

clean:
	-rm -rf $(O)
	-rm -f $(TARGET) $(HEADERS)
	-rm -fr tcppack $(TCPPACK_SOURCES) $(TCPPACK_HEADERS)

.PHONY: all clean install patch tcppack-copy update-patch
