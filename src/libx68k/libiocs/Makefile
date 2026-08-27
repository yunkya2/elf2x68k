RELPATH = ..
include $(RELPATH)/Common.mk

G = src
XINCLUDEDIR = $(INCLUDEDIR)/x68k
OVERRIDES = $(wildcard overrides/*)

TARGET = $(LIBDIR)/libx68kiocs.a
HEADERS = $(addprefix $(XINCLUDEDIR)/,iocs.h iocs_inline.h iocs_proto.h iocscall.h)

all: $(TARGET)

$(G) $(O) $(LIBDIR) $(XINCLUDEDIR):
	@mkdir -p $@

$(G)/.generated: iocscall.csv iocscall_gen.py iocs.h overrides $(OVERRIDES) | $(G) $(XINCLUDEDIR)
	./iocscall_gen.py \
		--inline-h $(XINCLUDEDIR)/iocs_inline.h \
		--proto-h $(XINCLUDEDIR)/iocs_proto.h \
		--def-h $(XINCLUDEDIR)/iocscall.h \
		--out-dir $(G)
	cp -p iocs.h $(XINCLUDEDIR)/iocs.h
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
