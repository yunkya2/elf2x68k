#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	common.sh
#
#		m68k-xelf toolchain をビルドするための共通設定
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2022 Yosshin(@yosshin4004)
#	Copyright (C) 2023,2024 Yuichi Nakamura (@yunkya2)
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


#
# 参考
#	How to Build a GCC Cross-Compiler
#		https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
#		https://gist.github.com/preshing/41d5c7248dea16238b60
#	newlibベースのgccツールチェインの作成
# 		https://memo.saitodev.com/home/arm/arm_gcc_newlib/
# 	Installing GCC: Configuration
# 		https://pipeline.lbl.gov/code/3rd_party/licenses.win/gcc-3.4.4-999/INSTALL/configure.html
#


#-----------------------------------------------------------------------------
# 設定
#
#	debian 系のディストリビューションで stable とされている構成に倣っている。
#-----------------------------------------------------------------------------

# gcc の ABI
GCC_ABI=m68k-elf

# binutils
BINUTILS_VERSION="2.41"
BINUTILS_ARCHIVE="binutils-${BINUTILS_VERSION}.tar.bz2"
BINUTILS_SHA512SUM="8c4303145262e84598d828e1a6465ddbf5a8ff757efe3fd981948854f32b311afe5b154be3966e50d85cf5d25217564c1f519d197165aac8e82efcadc9e1e47c"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${BINUTILS_ARCHIVE}"
BINUTILS_DIR="binutils-${BINUTILS_VERSION}"

# gcc
GCC_VERSION="13.2.0"
GCC_ARCHIVE="gcc-${GCC_VERSION}.tar.gz"
GCC_SHA512SUM="41c8c77ac5c3f77de639c2913a8e4ff424d48858c9575fc318861209467828ccb7e6e5fe3618b42bf3d745be8c7ab4b4e50e424155e691816fa99951a2b870b9"
GCC_URL="https://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION}/${GCC_ARCHIVE}"
GCC_DIR="gcc-${GCC_VERSION}"

# newlib
NEWLIB_VERSION="4.3.0.20230120"
NEWLIB_ARCHIVE="newlib-${NEWLIB_VERSION}.tar.gz"
NEWLIB_SHA512SUM="4a06309d36c2255fef8fc8f2d133cafa850f1ed2eddfb27b5d45f5d16af69e0fca829a0b4c9b34af4ed3a28c6fcc929761e0ee823a4229f35c2853d432b5e7ef"
NEWLIB_URL="ftp://sourceware.org/pub/newlib/${NEWLIB_ARCHIVE}"
NEWLIB_DIR="newlib-${NEWLIB_VERSION}"

# gcc ビルド用ワークディレクトリ
GCC_BUILD_DIR="build_gcc"


#-----------------------------------------------------------------------------
# 準備
#-----------------------------------------------------------------------------

# エラーが起きたらそこで終了させる。
set -e

CPU="m68000"
TARGET=${GCC_ABI}
PREFIX="m68k-xelf-"
PROGRAM_PREFIX=${PREFIX}
NUM_PROC=$(nproc)
ROOT_DIR="${PWD}"
INSTALL_DIR="${ROOT_DIR}/m68k-xelf"
DOWNLOAD_DIR="${ROOT_DIR}/download"
BUILD_DIR="${ROOT_DIR}/${GCC_BUILD_DIR}/build"
SRC_DIR="${ROOT_DIR}/${GCC_BUILD_DIR}/src"
WITH_CPU=${CPU}

export LC_ALL="C"
export LC_CTYPE="C"
export LANG="en_US.UTF-8"
