# elf2x68k

## 概要

elf2x68k は、シャープ X680x0 用実行ファイル(X 形式)を PC の Unix/Linux 系環境上で開発するためのクロス開発環境です。m68k 用クロスツールチェイン (gcc, binutils, newlib) から出力される ELF ファイルを変換スクリプト elf2x68k.py で変換することで、X68k で実行可能な X 形式ファイルを出力します。

(従来は xdev68k (https://github.com/yosshin4004/xdev68k) に含まれる m68k-toolchain を利用していたため、インストールに xdev68k が必要でしたが、自前でツールチェインを持つことで単独使用できるようになりました)

xdev68k によるクロス開発環境とは以下のような違いがあります。

* ツールチェインのコマンド名が `m68k-elf-*` から `m68k-xelf-*` に変わります (例: `m68k-xelf-gcc`)
* コンパイラドライバ (`m68k-xelf-gcc`) から直接 X 形式ファイルが出力されます。ネイティブの gcc を使用するのと同様の感覚で X 形式ファイルを得ることができます。
* アセンブラやリンカは HAS, HLK ではなく GNU binutils の GNU as, GNU ld を使用します。このため、アセンブラの書式には HAS などで用いられるモトローラ形式でなく [MIT形式](https://sourceware.org/binutils/docs/as/M68K_002dSyntax.html) (GASフォーマット) を使用する必要があります。
* C標準ライブラリには [Newlib](https://sourceware.org/newlib/) に X68k 対応を追加したものを使用します。このため、C Compiler PRO-68K や X680x0 libc で提供される関数は使用できません。Human 68kの DOS コールや IOCS コールは独自ライブラリから利用可能です。

## インストール

### バイナリ配布

x86_64 Linux と MSYS2 MinGW 64bit 向けはバイナリで配布しています
(Linux 版は Windows 11 の WSL2 にインストールした Ubuntu-20.04 でのみ動作確認しています)。

バイナリ配布の tarball を任意のディレクトリに展開し、`m68k-xelf/bin` にパスを通すことで使用できるようになります。

### ソースコードからのビルド

Linux 環境または MSYS2 MinGW 64bit 環境上で本リポジトリを clone して、

```
make all
```

で、必要なファイルをダウンロードしてビルドしたツールチェインと X68k 対応ファイルを `m68k-xelf` にインストールします。バイナリ配布同様に、`m68k-xelf/bin` にパスを通すと使用できるようになります。

その他、Makefile で以下のターゲットを指定することができます。

```
make m68k-xelf - m68k-xelf ツールチェインのビルドのみを行います
make download  - ツールチェインビルドに必要なファイルのダウンロードのみを行います
make install   - m68k-xelf に X68k 対応ファイルのインストールのみ行います
make uninstall - m68k-xelf の X68k 対応ファイルを削除します
make clean     - ビルドの生成物を削除します (ダウンロードしたアーカイブは削除しません)
make pristine  - ダウンロードアーカイブも含めて削除
make help      - 指定可能なターゲットを表示します
```

## 実行例

テストとして、以下のようなサンプルをコンパイルしてみます。

```
#include <stdio.h>
int main()
{
  printf("Hello world.\n");
  return 0;
}
```

この内容のファイル `sample.c` を作成し、以下のコマンドを実行します。

```
m68k-xelf-gcc -o sample.x sample.c
```

ソースコードがコンパイルされ、`sample.x`, `sample.x.elf`, `sample.x.elf.2` の 3 つのファイルが生成されます。
* `sample.x` は X68k の X 形式実行ファイルなので、実機やエミュレータなどの環境で実行できます。
* `sample.x.elf`, `sample.x.elf.2` は、X 形式実行ファイルを生成するために使用した ELF ファイルです。`m68k-xelf-readelf` や `m68k-xelf-objdump` などの ELF ファイルを扱うコマンドはこのファイルに対して実行することができます。

このようにリンク後に X 形式実行ファイルと ELF ファイルが生成されることを除けば、使い方は通常の gcc と同じです。もちろんコンパイルとリンクを分けて実行することも可能ですが、リンクは GNU リンカ `m68k-xelf-ld` を直接呼び出すことは避けて、コンパイラドライバ `m68k-xelf-gcc` から実行するようにしてください
(ELF → X 形式の変換を gcc の specs ファイルの記述によって行っているため)。

## ライブラリ

### C 標準ライブラリ

elf2x68k は C 標準ライブラリに [Newlib](https://sourceware.org/newlib/) を使用しています。
Newlib で提供しているライブラリ関数の仕様は、以下のページを参照してください。

* [Red Hat newlib C Library Documentation](https://sourceware.org/newlib/)
* [Red Hat newlib C Math Library Documentation](https://sourceware.org/newlib/)

ファイル入出力では、Human68k の仕様にしたがってバイナリファイルとテキストファイルをサポートします。
* `open()` のオープンモードでは `O_BINRAY` (バイナリモード)と `O_TEXT` (テキストモード)を指定できます。
* `fopen()` などのオープンモードでは `"b"` (バイナリモード)と `"t"` (テキストモード)を指定できます。

どちらも、指定がない場合にはテキストモードでオープンされます。

### X68k 対応ライブラリ

Newlib のライブラリ関数に加えて、X68k 対応のために以下のライブラリを提供しています。

* libx68k  
Newlib のライブラリ関数が利用する、OS 依存のファイル入出力などのシステムコール関数 (open(), close(), read(), write() 等)を提供します。
* libdos  
Human68k の DOS コールをサポートします。
ヘッダファイル `x68k/dos.h` を include することで利用できます。
* libiocs  
X680x0 の IOCS コールをサポートします。
ヘッダファイル `x68k/iocs.h` を include することで利用できます。

これらのライブラリは、コンパイラドライバ `m68k-xelf-gcc` からリンクを行う際にデフォルトでリンクされます。

## 制約事項

* libx68k のシステムコール関数に不十分な実装が残っています。
* C++ 周りの機能はあまりテストされていません。
* デバッグ情報の出力に対応していません。
* etc.

## 謝辞

elf2x68k の開発には以下のソースコードを参考にさせていただきました。

* m68k クロスツールチェインのビルドスクリプトは、xdev68k 内のスクリプト [build_m68k-toolchain.sh](https://github.com/yosshin4004/xdev68k/blob/main/build_m68k-toolchain.sh) を元にしています。開発された よっしん氏 (@yosshin4004) に感謝いたします。
* Newlib の X68k 対応は、[newlib-1.19.0-human68k](https://github.com/Lydux/newlib-1.19.0-human68k) の [human68k対応コード](https://github.com/Lydux/newlib-1.19.0-human68k/tree/master/newlib/libc/sys/human68k) を元にしています。開発された Lyderic Maillet 氏 に感謝いたします。

## ライセンス

* src/*  
BSDライセンスが適用されます。
* scripts/*  
元となった xdev68k 内のスクリプト [build_m68k-toolchain.sh](https://github.com/yosshin4004/xdev68k/pblob/main/build_m68k-toolchain.sh) と同様に、Apache License Version 2.0 が適用されます。
* binutils, gcc, newlib  
それぞれの配布元が規定したライセンス条件が適用されます。アーカイブ内の COPYING ファイル等を参照してください。
