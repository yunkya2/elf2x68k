#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#	gcc-stage2.sh
#
#		m68k-xelf toolchain の gcc stage2 ビルド
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
# gcc のビルド（stage2）
#
#	残りを一括実行する。
#
#	--with-arch=m68k を指定することで、ColdFire 用の libgcc バリエーションが
#	大量に生成されることを回避している。
#-----------------------------------------------------------------------------

gcc_configure () {
../../src/${GCC_DIR}/configure \
    --prefix=${INSTALL_DIR} \
    --program-prefix=${PROGRAM_PREFIX} \
    --target=${TARGET} \
    --enable-lto \
    --enable-languages=c,c++ \
    --with-arch=m68k \
    --with-cpu=${WITH_CPU} \
    --with-newlib \
    --enable-multilib \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --with-system-zlib \
    --with-pkgversion="elf2x68k" \
    --with-bugurl="https://github.com/yunkya2/elf2x68k/issues" \

}

#	libstdc++.a のみを縮小版 (-fno-rtti -fno-exceptions) でビルド、インストールする

#	XC 互換の ABI でビルド
export CFLAGS_FOR_TARGET="-g -O2 -fcall-used-d2 -fcall-used-a2"
export CXXFLAGS_FOR_TARGET="-g -O2 -fcall-used-d2 -fcall-used-a2 -fno-rtti -fno-exceptions"

mkdir -p ${BUILD_DIR}/${GCC_DIR}_stage2s
cd ${BUILD_DIR}/${GCC_DIR}_stage2s
gcc_configure

make -j${NUM_PROC} all-target-libstdc++-v3 2<&1 | tee build.gcc-stage2.1.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi
make install-strip-target-libstdc++-v3 2<&1 | tee build.gcc-stage2.2.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi

#	縮小版の libstdc++.a を移動
for f in `find ${INSTALL_DIR} -name libstdc++.a`; do
	mv $f `dirname $f`/libstdc++small.a
done

#	通常のコンフィグでビルド、インストールする

#	XC 互換の ABI でビルド
export CFLAGS_FOR_TARGET="-g -O2 -fcall-used-d2 -fcall-used-a2"
export CXXFLAGS_FOR_TARGET="-g -O2 -fcall-used-d2 -fcall-used-a2"

mkdir -p ${BUILD_DIR}/${GCC_DIR}_stage2
cd ${BUILD_DIR}/${GCC_DIR}_stage2
gcc_configure

make -j${NUM_PROC} 2<&1 | tee build.gcc-stage2.1.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi
make install-strip 2<&1 | tee build.gcc-stage2.2.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	exit 1;
fi

cd ${ROOT_DIR}

#------------------------------------------------------------------------------
# 正常終了
#------------------------------------------------------------------------------

echo ""
echo "-----------------------------------------------------------------------------"
echo "The building process is completed successfully."
echo "-----------------------------------------------------------------------------"
echo ""
exit 0
