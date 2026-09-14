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
BINUTILS_VERSION="2.46.0"
BINUTILS_ARCHIVE="binutils-${BINUTILS_VERSION}.tar.xz"
BINUTILS_SHA512SUM="32f880bb4f69351f4ae54a5d00359625c6c49d8e76624fb5cffdf174c79c8d3212f66225b81c12933c6ed59604ab652560773dd92fab384b930c97a9d4e1fdf2"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${BINUTILS_ARCHIVE}"
BINUTILS_DIR="binutils-${BINUTILS_VERSION}"

# gcc
GCC_VERSION="13.5.0"
GCC_ARCHIVE="gcc-${GCC_VERSION}.tar.xz"
GCC_SHA512SUM="709237ff8f10d46eb10cad53a71bdcacbd3d56f4559e9a5bb3323f743fdba78b7e505586135560b27e88320927a065ec4f5e45273d5504b542f67c7326eb683c"
GCC_URL="https://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION}/${GCC_ARCHIVE}"
GCC_DIR="gcc-${GCC_VERSION}"

# newlib
NEWLIB_VERSION="4.6.0.20260123"
NEWLIB_ARCHIVE="newlib-${NEWLIB_VERSION}.tar.gz"
NEWLIB_SHA512SUM="ffa16d6465c0b429264c46395fa760fbcf072d3ff86e87330ba1f483efcfe66393ef83b03932759444a0ebeaef94d3ca58a59e91ab7b97b2a6ac6be2e7589657"
NEWLIB_URL="https://sourceware.org/pub/newlib/${NEWLIB_ARCHIVE}"
NEWLIB_DIR="newlib-${NEWLIB_VERSION}"

# gdb
GDB_VERSION="17.2"
GDB_ARCHIVE="gdb-${GDB_VERSION}.tar.xz"
GDB_SHA512SUM="7794c5a185be7ed5e7ad1000c4ff7d8497c80425a1bc108aab8fd3dd8ecdde034e294dfd65b25c6b0dcd8ed2a240caf07293f3e73791b6cfc890d580d0af4581"
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
