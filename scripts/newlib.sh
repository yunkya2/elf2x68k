#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	newlib.sh
#
#		m68k-xelf toolchain の newlib ビルド
#		(事前に download.sh でファイルをダウンロードしておく必要がある)
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

# 共通設定を読み込み
. scripts/common.sh

#-----------------------------------------------------------------------------
# newlib のビルド
#-----------------------------------------------------------------------------

cd ${DOWNLOAD_DIR}
tar zxvf ${NEWLIB_ARCHIVE} -C ${SRC_DIR}

#	timezoneのデフォルトをJST-9にするためのパッチ
cd ${SRC_DIR}/${NEWLIB_DIR}
patch -p1 -N < ${PATCH_DIR}/newlib-tz-jst.patch

newlib_build () {
    mkdir -p ${BUILD_DIR}/${NEWLIB_DIR}$1
    cd ${BUILD_DIR}/${NEWLIB_DIR}$1
    ${SRC_DIR}/${NEWLIB_DIR}/configure \
        --prefix=${INSTALL_DIR} \
        --target=${TARGET} \
        --enable-newlib-io-long-long \
        --enable-newlib-io-c99-formats \
        $2 \

    make -j${NUM_PROC} 2<&1 | tee build.newlib.1.log
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        exit 1;
    fi
    make install | tee build.newlib.2.log
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        exit 1;
    fi
}


if [ "${SIMPLE}" = "" ]; then
    # newlib-nano をビルド、インストールする
        newlib_build "-nano" "\
        --enable-newlib-nano-malloc \
        --enable-newlib-reent-small \
        --disable-newlib-wide-orient \
        --enable-target-optspace \
        --disable-newlib-multithread \
        --enable-newlib-nano-formatted-io \
    "
    # libc-nano.a を移動
    for f in `find ${INSTALL_DIR} -name libc.a`; do
    	mv `dirname $f`/libc.a `dirname $f`/libc-nano.a
    done
fi

# 通常版 newlib をビルド、インストールする
newlib_build "" ""

cd ${ROOT_DIR}

#------------------------------------------------------------------------------
# 正常終了
#------------------------------------------------------------------------------

echo ""
echo "-----------------------------------------------------------------------------"
echo "The newlib building process is completed successfully."
echo "-----------------------------------------------------------------------------"
echo ""
exit 0
