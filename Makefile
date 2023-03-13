#------------------------------------------------------------------------------
#
#	Makefile for elf2x68k
#
#	Copyright (C) 2023 Yuichi Nakamura (@yunkya2)
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

all:


toolchain: binutils gcc-stage1 newlib gcc-stage2

binutils: download
	scripts/binutils.sh

gcc-stage1: download
	scripts/gcc-stage1.sh

newlib: download
	scripts/newlib.sh

gcc-stage2: download
	scripts/gcc-stage2.sh

download:
	scripts/download.sh

clean:
	-rm -rf build_gcc
	-rm -rf m68k-xelf
	make clean -C src/libx68k

pristine: clean
	-rm -rf download

.PHONY:	all clean pristine
.PHONY:	download binutils gcc-stage1 newlib gcc-stage2
