RELPATH = ..
include $(RELPATH)/Common.mk

G = src
XINCLUDEDIR = $(INCLUDEDIR)/x68k
OVERRIDES = $(wildcard overrides/*)

TARGET = $(LIBDIR)/libx68kdos.a
HEADERS = $(addprefix $(XINCLUDEDIR)/,dos.h dos_inline.h dos_proto.h doscall.h)

all: $(TARGET)

$(G) $(O) $(LIBDIR) $(XINCLUDEDIR):
	@mkdir -p $@

$(G)/.generated: doscall.csv doscall_gen.py dos.h overrides $(OVERRIDES) | $(G) $(XINCLUDEDIR)
	./doscall_gen.py \
		--inline-h $(XINCLUDEDIR)/dos_inline.h \
		--proto-h $(XINCLUDEDIR)/dos_proto.h \
		--def-h $(XINCLUDEDIR)/doscall.h \
		--out-dir $(G)
	cp -p dos.h $(XINCLUDEDIR)/dos.h
	@touch $@

$(O)/%.o: $(G)/%.S | $(O)
	$(CC) $(CFLAGS) -o $@ -c $<

$(TARGET): $(G)/.generated | $(LIBDIR)
	@$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(TARGET)-objs

.PHONY: $(TARGET)-objs
$(TARGET)-objs: $(addprefix $(O)/,$(patsubst %.S,%.o,$(notdir $(wildcard $(G)/*.S))))
	$(AR) $(ARFLAGS) $(TARGET) $^
	$(RANLIB) $(TARGET)

install: all

clean:
	-rm -f $(O)/*.o $(TARGET)

allclean: clean
	-rm -rf $(G) $(O)
	-rm -f $(HEADERS)

.PHONY: all clean allclean install
