#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	gdb.sh
#
#		m68k-xelf toolchain の gdb をビルド
#		(事前に download.sh でファイルをダウンロードしておく必要がある)
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2025 Yuichi Nakamura (@yunkya2)
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
# gdb のビルド
#-----------------------------------------------------------------------------

cd ${DOWNLOAD_DIR}
mkdir -p ${BUILD_DIR}/${GDB_DIR}
rm -rf ${SRC_DIR}/${GDB_DIR}
tar xvf ${GDB_ARCHIVE} -C ${SRC_DIR}

#	逆アセンブルでX68000のIOCS/DOSコール命令を表示させるためのパッチ
cd ${SRC_DIR}/${GDB_DIR}
patch -p1 -N < ${PATCH_DIR}/binutils-x68k.patch

cd ${BUILD_DIR}/${GDB_DIR}
${SRC_DIR}/${GDB_DIR}/configure \
    --prefix=${INSTALL_DIR} \
    --target=${TARGET} \
    --without-python \
    --with-mpc-include=${SRC_DIR}/${GCC_DIR}/mpc/src/ \
    --with-mpc-lib=${BUILD_DIR}/${GCC_DIR}_stage1/mpc/.libs/ \
    --with-mpfr-include=${SRC_DIR}/${GCC_DIR}/mpfr/src/ \
    --with-mpfr-lib=${BUILD_DIR}/${GCC_DIR}_stage1/mpfr/.libs/ \
    --with-gmp-include=${BUILD_DIR}/${GCC_DIR}_stage1/gmp/ \
    --with-gmp-lib=${BUILD_DIR}/${GCC_DIR}_stage1/gmp/.libs/ \
    --with-system-zlib \

make -j${NUM_PROC} 2<&1 | tee build.GDB.1.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi
make install-strip 2<&1 | tee build.GDB.2.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi

cd ${ROOT_DIR}

#------------------------------------------------------------------------------
# 正常終了
#------------------------------------------------------------------------------

echo ""
echo "-----------------------------------------------------------------------------"
echo "The GDB building process is completed successfully."
echo "-----------------------------------------------------------------------------"
echo ""
exit 0
