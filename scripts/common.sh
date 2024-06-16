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
BINUTILS_VERSION="2.42"
BINUTILS_ARCHIVE="binutils-${BINUTILS_VERSION}.tar.bz2"
BINUTILS_SHA512SUM="d2c6d264bbeaaaf2aad1fa3fc417c1841a5dd4a299fa47c47d15adb821c22dae733e58f19ebcfea3b0c5890ba56e4a5f92ab55128a572d585bcd5172b63f456c"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${BINUTILS_ARCHIVE}"
BINUTILS_DIR="binutils-${BINUTILS_VERSION}"

# gcc
GCC_VERSION="14.1.0"
GCC_ARCHIVE="gcc-${GCC_VERSION}.tar.gz"
GCC_SHA512SUM="d1ef7c8ba4134e7c64f715665f41eef5af30662352503442241a73772ce03de804ea4ca667353731b67c9fc66bdc2faec2bec3fd3d5bce1826c8ad545698345b"
GCC_URL="https://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION}/${GCC_ARCHIVE}"
GCC_DIR="gcc-${GCC_VERSION}"

# newlib
NEWLIB_VERSION="4.4.0.20231231"
NEWLIB_ARCHIVE="newlib-${NEWLIB_VERSION}.tar.gz"
NEWLIB_SHA512SUM="ea3baa0b7c9175aae024f0b7d272be092ef2c07483239a99329203e18a44bc23093d29e0ffcbe14bc591f610f0829eacd646cabb06d1c34aa23239cb1b814b46"
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
PATCH_DIR="${ROOT_DIR}/src/patch"
WITH_CPU=${CPU}

export LC_ALL="C"
export LC_CTYPE="C"
export LANG="en_US.UTF-8"
