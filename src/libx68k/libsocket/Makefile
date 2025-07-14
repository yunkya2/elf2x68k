TARGET = libsocket.a

include ../Common.mk

vpath %.c ..

CFLAGS += -I.. -Iinclude -DLIBSOCKET

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
    getsockopt.c \
    setsockopt.c \
    inet_ntoa.c \
    inet_aton.c \
    getnetnamadr.c \
    getservnamprt.c \
    getprotonamnum.c \
    getaddrinfo.c \

#    poll.c \

OBJ = $(LIB_SOURCES:.c=.o)

all: $(TARGET)

tcppack: TCPPACKB.LZH
	-rm -rf $@
	-mkdir $@
	(cd $@; ../../../../unlha/unlha.py x ../$<)

tcppack-copy: tcppack
	cat tcppack/include/network.h | tr -d \\r > network.h
	cat tcppack/include/tcpipdrv.h | tr -d \\r > tcpipdrv.h
	cat tcppack/src/libnetwork/search_ti_entry.c | tr -d \\r > search_ti_entry.c
	cat tcppack/src/libnetwork/gethostnamadr.c | tr -d \\r > gethostnamadr.c

patch: tcppack-copy
	patch -p4 < tcppack.patch

$(TCPPACK_SOURCES) $(TCPPACK_HEADERS): tcppack.patch
	$(MAKE) patch

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

$(TARGET): $(OBJ)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

%.o: %.c $(TCPPACK_HEADERS)
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o $(TARGET)
	-rm -fr tcppack $(TCPPACK_SOURCES) $(TCPPACK_HEADERS)

.PHONY: all clean patch tcppack-copy update-patch
