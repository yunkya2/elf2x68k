#!/usr/bin/bash
#------------------------------------------------------------------------------
#
#	gcc-stage1.sh
#
#		m68k-elfx toolchain の gcc stage1 ビルド
#		(事前に download.sh でファイルをダウンロードしておく必要がある)
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2022 Yosshin(@yosshin4004)
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

# 共通設定を読み込み

. scripts/common.sh

export PATH=${INSTALL_DIR}/bin:${PATH}

# ディレクトリ作成
mkdir -p ${INSTALL_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${SRC_DIR}

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

#
#	新しい mingw 環境では以下のようなエラーとなる。
#		../../../src/gcc-10.2.0/gcc/system.h:743:30: error: expected identifier before string constant
#		743 | #define abort() fancy_abort (__FILE__, __LINE__, __FUNCTION__)
#	応急処置として、問題を起こす行を除去する。
#	abort() は stdlib.h 内で宣言された実装のままの挙動となる。
#
if [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
	cat ${SRC_DIR}/${GCC_DIR}/gcc/system.h |\
	perl -e 'my $before="#define abort() fancy_abort (__FILE__, __LINE__, __FUNCTION__)";my $after="/* $before */";$before=quotemeta($before);while(<>){$_=~s/$before/$after/g;print $_;}' > ${SRC_DIR}/${GCC_DIR}/gcc/system.h.tmp;
	mv ${SRC_DIR}/${GCC_DIR}/gcc/system.h.tmp ${SRC_DIR}/${GCC_DIR}/gcc/system.h
fi

#
#	mingw 環境で gcc-12.2.0 のビルドを行うと stage-2 の PCH コンパイルでエラーになる問題を修正する。
#	https://github.com/brechtsanders/winlibs_mingw/issues/108
#	mingw 向けに当たっているパッチと同じものを当てる
#
if [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
	cd ${SRC_DIR}/${GCC_DIR}
	wget https://github.com/msys2/MINGW-packages/raw/efe952964b315b66104e332651d3b70c14e788ff/mingw-w64-gcc/0010-Fix-using-large-PCH.patch
	patch -p1 < 0010-Fix-using-large-PCH.patch
fi

cd ${SRC_DIR}/${GCC_DIR}
./contrib/download_prerequisites

cd ${BUILD_DIR}/${GCC_DIR}_stage1
`realpath --relative-to=./ ${SRC_DIR}/${GCC_DIR}`/configure \
    --prefix=${INSTALL_DIR} \
    --program-prefix=${PROGRAM_PREFIX} \
    --target=${TARGET} \
    --enable-lto \
    --enable-languages=c \
    --without-headers \
    --with-arch=m68k \
    --with-cpu=${WITH_CPU} \
    --with-newlib \
    --enable-interwork \
    --enable-multilib \
    --disable-shared \
    --disable-threads \

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
