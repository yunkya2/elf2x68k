TARGET = DEFSPTOOL.x

all: $(TARGET)

$(TARGET): DEFSPTOOL.BAS
	m68k-xelf-bas -o $@ $^

DEFSPTOOL.BAS:
	./getdefsp.sh

clean:
	-rm -f $(TARGET)*

pristine:
	-rm -rf $(TARGET)* DEFSPTOOL.BAS DEFSPTOOL.HLP download

.PHONY: all clean pristine