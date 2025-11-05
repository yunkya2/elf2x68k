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
BINUTILS_VERSION="2.44"
BINUTILS_ARCHIVE="binutils-${BINUTILS_VERSION}.tar.xz"
BINUTILS_SHA512SUM="b85d3bbc0e334cf67a96219d3c7c65fbf3e832b2c98a7417bf131f3645a0307057ec81cd2b29ff2563cec53e3d42f73e2c60cc5708e80d4a730efdcc6ae14ad7"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${BINUTILS_ARCHIVE}"
BINUTILS_DIR="binutils-${BINUTILS_VERSION}"

# gcc
GCC_VERSION="13.4.0"
GCC_ARCHIVE="gcc-${GCC_VERSION}.tar.xz"
GCC_SHA512SUM="9b4b83ecf51ef355b868608b8d257b2fa435c06d2719cb86657a7c2c2a0828ff4ce04e9bac1055bbcad8ed5b4da524cafaef654785e23a50233d95d89201e35f"
GCC_URL="https://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION}/${GCC_ARCHIVE}"
GCC_DIR="gcc-${GCC_VERSION}"

# newlib
NEWLIB_VERSION="4.5.0.20241231"
NEWLIB_ARCHIVE="newlib-${NEWLIB_VERSION}.tar.gz"
NEWLIB_SHA512SUM="d391ea3ac68ddb722909ef790f81ba4d6c35d9b2e0fcdb029f91a6c47db9ee94a686a2bdff211fb84025e1a317e257acfa59abda3fd2bc6609966798e1c604dc"
NEWLIB_URL="https://sourceware.org/pub/newlib/${NEWLIB_ARCHIVE}"
NEWLIB_DIR="newlib-${NEWLIB_VERSION}"

# gdb
GDB_VERSION="16.3"
GDB_ARCHIVE="gdb-${GDB_VERSION}.tar.xz"
GDB_SHA512SUM="fffd6689c3405466a179670b04720dc825e4f210a761f63dd2b33027432f8cd5d1c059c431a5ec9e165eedd1901220b5329d73c522f9a444788888c731b29e9c"
GDB_URL="https://ftp.gnu.org/gnu/gdb/${GDB_ARCHIVE}"
GDB_DIR="gdb-${GDB_VERSION}"

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

if [ -x "$(command -v nproc)" ]; then
	NUM_PROC=$(nproc)
else
	NUM_PROC=$(sysctl -n hw.physicalcpu)
fi

if [ -x "$(command -v sha512sum)" ]; then
	SHA512SUM="sha512sum"
else
	SHA512SUM="shasum -a 512"
fi

# インストール先ディレクトリ作成 (デフォルトは ./m68k-xelf)
INSTALL_DIR=${INSTALL_DIR:-"m68k-xelf${BUILD_SUFFIX}"}
mkdir -p ${INSTALL_DIR}
INSTALL_DIR=$(realpath ${INSTALL_DIR})

ROOT_DIR="${PWD}"
DOWNLOAD_DIR="${ROOT_DIR}/download"
BUILD_DIR="${ROOT_DIR}/${GCC_BUILD_DIR}/build${BUILD_SUFFIX}"
SRC_DIR="${ROOT_DIR}/${GCC_BUILD_DIR}/src"
PATCH_DIR="${ROOT_DIR}/src/patch"
WITH_CPU=${CPU}

# ライブラリビルド用のコマンド設定
export CC_FOR_TARGET=${PROGRAM_PREFIX}gcc
export CXX_FOR_TARGET=${PROGRAM_PREFIX}g++
export LD_FOR_TARGET=${PROGRAM_PREFIX}ld
export AS_FOR_TARGET=${PROGRAM_PREFIX}as
export AR_FOR_TARGET=${PROGRAM_PREFIX}ar
export RANLIB_FOR_TARGET=${PROGRAM_PREFIX}ranlib

# ライブラリを XC 互換の ABI でビルド
export CFLAGS_FOR_TARGET="-g -O2 -fcall-used-d2 -fcall-used-a2"
export CXXFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}

# ライブラリビルド用のパスを設定
# (クロスビルドの場合はm68k-xelfツールチェインを使用する)
if [ "${HOST_OPTION}" = "" ]; then
	export PATH=${INSTALL_DIR}/bin:${PATH}
else
	export PATH=${ROOT_DIR}/${GCC_BUILD_DIR}/m68k-xelf/bin:${PATH}
fi

export LC_ALL="C"
export LC_CTYPE="C"
export LANG="en_US.UTF-8"

# ディレクトリ作成
mkdir -p ${BUILD_DIR}
mkdir -p ${SRC_DIR}
