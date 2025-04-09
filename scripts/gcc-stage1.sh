#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	gcc-stage1.sh
#
#		m68k-xelf toolchain の gcc stage1 ビルド
#		(事前に download.sh でファイルをダウンロードしておく必要がある)
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

# 共通設定を読み込み
. scripts/common.sh

#-----------------------------------------------------------------------------
# gcc のビルド（stage1）
#
#	C クロスコンパイラを構築する。
#	msys 上で起きるファイルパス問題を回避するため、configure を相対パスで
#	起動している。
#-----------------------------------------------------------------------------

cd ${DOWNLOAD_DIR}
mkdir -p ${BUILD_DIR}/${GCC_DIR}_stage1
tar xvf ${GCC_ARCHIVE} -C ${SRC_DIR}

# 事前にダウンロードしておいたライブラリをコピー
cp {gmp,mpfr,mpc,isl}-* ${SRC_DIR}/${GCC_DIR}

# MinGW64環境でビルドエラーになる問題の修正
cd ${SRC_DIR}/${GCC_DIR}
patch -p1 < ${PATCH_DIR}/gcc-13.3.0-libcpp.patch

cd ${SRC_DIR}/${GCC_DIR}
./contrib/download_prerequisites

cd ${BUILD_DIR}/${GCC_DIR}_stage1
../../src/${GCC_DIR}/configure \
    --prefix=${INSTALL_DIR} \
    --program-prefix=${PROGRAM_PREFIX} \
    --target=${TARGET} \
    --enable-lto \
    --enable-languages=c \
    --without-headers \
    --with-arch=m68k \
    --with-cpu=${WITH_CPU} \
    --with-newlib \
    --enable-multilib \
    --disable-shared \
    --disable-threads \
    --with-system-zlib \

make -j${NUM_PROC} all-gcc 2<&1 | tee build.gcc-stage1.1.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi
make install-gcc 2<&1 | tee build.gcc-stage1.2.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi

cd ${ROOT_DIR}

#------------------------------------------------------------------------------
# 正常終了
#------------------------------------------------------------------------------

echo ""
echo "-----------------------------------------------------------------------------"
echo "The gcc stage 1 building process is completed successfully."
echo "-----------------------------------------------------------------------------"
echo ""
exit 0
