#------------------------------------------------------------------------------
#
#	Makefile for elf2x68k
#
#	Copyright (C) 2023-2025 Yuichi Nakamura (@yunkya2)
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#	    http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#
#------------------------------------------------------------------------------

help:
	@echo "make all          - Build m68k-xelf development environment"
	@echo "make simple       - Build simple environment (without C++, newlib-nano and gdb)"
	@echo "make mingw        - Build MinGW binary (Linux only)"
	@echo "make mingw-simple - Build MinGW binary (Linux only) (without C++, newlib-nano and gdb)"
	@echo "make m68k-xelf    - Build m68k cross toolchain only"
	@echo "make download     - Download prerequisite archives only"
	@echo "make install      - Install X68k support files only"
	@echo "make uninstall    - Uninstall X68k support files"
	@echo "make clean        - Remove artifacts"
	@echo "make pristine     - Remove artifacts including downloaded archives"
	@echo "make help         - Show this message"

all:          m68k-xelf              install
simple:       m68k-xelf-simple       install-simple
mingw:        m68k-xelf-mingw        install-mingw
mingw-simple: m68k-xelf-mingw-simple install-mingw-simple

TARGETS = binutils gcc-stage1 newlib gcc-stage2 gdb
TARGETS_SIMPLE = $(addsuffix -simple,$(filter-out gdb,$(TARGETS)))
TARGETS_MINGW = $(addsuffix -mingw,$(TARGETS))
TARGETS_MINGW_SIMPLE = $(addsuffix -mingw-simple,$(filter-out gdb,$(TARGETS)))

m68k-xelf:              $(TARGETS)
m68k-xelf-simple:       $(TARGETS_SIMPLE)
m68k-xelf-mingw:        $(TARGETS_MINGW)
m68k-xelf-mingw-simple: $(TARGETS_MINGW_SIMPLE)

$(TARGETS) install uninstall: download
	scripts/$@.sh

$(TARGETS_SIMPLE) install-simple uninstall-simple: download
	BUILD_SUFFIX="-simple" \
	SIMPLE=1 \
	scripts/$(patsubst %-simple,%,$@).sh

$(TARGETS_MINGW) install-mingw uninstall-mingw: download build_gcc/m68k-xelf
	BUILD_SUFFIX="-mingw" \
	HOST_OPTION="--host=x86_64-w64-mingw32" \
	CC=x86_64-w64-mingw32-gcc-posix \
	CXX=x86_64-w64-mingw32-g++-posix \
	scripts/$(patsubst %-mingw,%,$@).sh

$(TARGETS_MINGW_SIMPLE) install-mingw-simple uninstall-mingw-simple: download  build_gcc/m68k-xelf
	BUILD_SUFFIX="-mingw-simple" \
	SIMPLE=1 \
	HOST_OPTION="--host=x86_64-w64-mingw32" \
	CC=x86_64-w64-mingw32-gcc-posix \
	CXX=x86_64-w64-mingw32-g++-posix \
	scripts/$(patsubst %-mingw-simple,%,$@).sh

build_gcc/m68k-xelf:
	if [ -d m68k-xelf/bin ]; then \
		$(MAKE) uninstall; \
	else \
		$(MAKE) m68k-xelf; \
	fi
	cp -pr m68k-xelf build_gcc

download:
	scripts/download.sh

clean:
	-rm -rf build_gcc
	-rm -rf m68k-xelf
	-rm -rf $(foreach s, -simple -mingw -mingw-simple,$(addsuffix $s, m68k-xelf))
	make clean -C src/libx68k

pristine: clean
	-rm -rf download

GIT_REPO_VERSION=$(shell git describe --tags --always)
ARCHIVE="elf2x68k-`uname -s|sed 's/_.*//'`-${GIT_REPO_VERSION}"
ifeq ("$(shell tar --version|grep bsdtar)","")
UID=owner
GID=group
else
UID=uid
GID=gid
endif

release: uninstall install
	tar -c -v -j -f ${ARCHIVE}.tar.bz2 --${UID}=0 --${GID}=0 m68k-xelf

.PHONY:	all help
.PHONY:	download clean pristine release
.PHONY:	m68k-xelf $(TARGETS) install uninstall
.PHONY:	$(foreach s, -simple -mingw -mingw-simple,$(addsuffix $s, m68k-xelf $(TARGETS) install uninstall))
