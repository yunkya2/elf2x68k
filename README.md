# X680x0 クロス開発環境 elf2x68k

## 概要

elf2x68k はシャープ X680x0 用実行ファイル(X 形式)を PC の Unix/Linux 系環境や macOS 上で開発するためのクロス開発環境です。m68k 用クロスツールチェイン (gcc, binutils) から出力される ELF ファイルを変換して、 X68k で実行可能な X 形式ファイルを出力します。

更に、X-BASIC から C へのコンバートにも対応しています。クロス環境上で X-BASIC プログラムを変換、コンパイルして X 形式ファイルを出力することができます。

## 特徴

* 最新の binutils (2.44)、gcc (13.4.0) を用いた X68k のクロス開発が可能です
* binutils, gcc の各コマンド名の頭に `m68k-xelf-` が付いたコマンドがクロスツールチェインとなります (例: `m68k-xelf-gcc`)
* コンパイラドライバ (`m68k-xelf-gcc`) から直接 X 形式ファイルが出力されます。ネイティブの gcc を使用するのと同様の感覚で X 形式ファイルを得ることができます
* ツールチェインから出力される ELF ファイルに含まれるデバッグ情報を利用して、[gdbserver-x68k](https://github.com/yunkya2/gdbserver-x68k) を用いたリモートデバッグが可能です
* X68k 標準の開発環境で用いられているオブジェクトファイルやライブラリファイル (\*.o/\*.a/\*.l) を ELF 形式に変換するスクリプト `x68k2elf.py` を用意しています
* 標準 C ライブラリに以下の 2 種類を用意しています。用途によって使い分けが可能です
  * [Newlib](https://sourceware.org/newlib/) (組み込みシステム等で使われている標準 C ライブラリ)
  * C Compiler PRO-68K v2.1 (XC) の 標準 C ライブラリ
* アセンブラには GNU binutils の as を使用します。680x0 アセンブリ言語の書式は、HAS.X などで用いられているモトローラ形式でなく [MIT形式](https://sourceware.org/binutils/docs/as/M68K_002dSyntax.html) (GASフォーマット) となります
* X-BASIC to C コンバータ `bas2c.py` とそのサポートコマンド `m68k-xelf-bas` により、X-BASIC で書かれたプログラムを変換、コンパイルして X 形式ファイルを得ることができます

## インストール

### Linux/MinGW 向け

以下の環境向けバイナリを配布しています
* x86_64 Linux (Windows 11 の WSL2 にインストールした Ubuntu-20.04 で動作確認)
* MSYS2 MinGW 64bit

[Release](https://github.com/yunkya2/elf2x68k/releases) から利用する環境のアーカイブをダウンロードし、任意のディレクトリに展開してください。
`m68k-xelf/bin` にパスを通すことで使用できるようになります。

アーカイブにはライブラリとして Newlib 環境のみが含まれています。
展開した `m68k-xelf` ディレクトリにある `install-xclib.sh` スクリプトを実行することで、無償公開されている C Compiler PRO-68K ver2.1 (XC) をダウンロード、インストールします。
これによって、Newlib に加えて XC のライブラリも利用できるようになります。
* X-BASIC to C コンバータを利用する場合には必ず実行してください。
* インストール後に `m68k-xelf` ディレクトリを移動した場合は `install-xclib.sh` スクリプトを再度実行してください (スクリプト内で実行時の絶対パスを記録する箇所があるため)。

### macOS 向け

macOS 向けは Homebrew からインストールできます (M3 Macbook Air / macOS 15.6.1 (Sequoia) で動作確認)。
Homebrew がインストールされている環境でコマンドラインから

```
brew install yunkya2/tap/elf2x68k
```
を実行すると、ソースコードをダウンロードしてビルド、インストールを行います
(M3 Macbook Air で 30 分程度かかります)。

>[!WARNING]
> elf2x68k 20250410 以前のバージョンでリモートデバッグに必要だった m68k-gdb パッケージは elf2x68k に統合されたため不要になりました。インストールされている場合は事前に
> ```
> brew uninstall m68k-gdb
> ```
> を実行してアンインストールしておいてください。

XC ライブラリのインストールも合わせて行いますので、`install-xclib.sh` スクリプトは実行不要です。

### ソースコードからのビルド

ソースコードからビルドを行う方法は [README-elf2x68k.md](README-elf2x68k.md) を参照してください

## サンプルコード

C や C++、X-BASIC to C のサンプルコードを [elf2x68k-samples](https://github.com/yunkya2/elf2x68k-sample) リポジトリに用意しています。
サンプルコードの説明は [README.md](https://github.com/yunkya2/elf2x68k-sample/blob/master/README.md) を参照してください。

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

ソースコードがコンパイルされ、`sample.x`, `sample.x.elf` の 2 つのファイルが生成されます。
* `sample.x` は X68k の X 形式実行ファイルなので、実機やエミュレータなどの環境で実行できます。
* `sample.x.elf` は、X 形式実行ファイルを生成するために使用した ELF ファイルです。`m68k-xelf-readelf` や `m68k-xelf-objdump` などの ELF ファイルを扱うコマンドはこのファイルに対して実行することができます。

このようにリンク後に X 形式実行ファイルと ELF ファイルが生成されることを除けば、使い方は通常の gcc と同じです。もちろんコンパイルとリンクを分けて実行することも可能ですが、リンクは GNU リンカ `m68k-xelf-ld` を直接呼び出すことは避けて、コンパイラドライバ `m68k-xelf-gcc` から実行するようにしてください
(ELF → X 形式の変換を gcc の specs ファイルの記述によって行っているため)。

### -o オプションによる出力ファイル名の指定

`m68k-xelf-gcc` コマンドの `-o` オプションで出力ファイル名を指定することができます。
通常、このオプションでは最終的に出力する X 形式実行ファイルの名前を指定しますが、指定したファイル名の拡張子が `.out` や `.elf` だった場合は中間生成物の ELF ファイルの指定とみなし、最終的な出力ファイルは拡張子を `.x` に変更したファイルとなります。

`-o` オプションで指定するファイル名の拡張子とELF ファイル、X 形式ファイルの関係は以下のようになります。

| 拡張子 | ELF ファイル名 | X形式実行ファイル名 |
|------------------------|----------------------------|---------------------------------|
| .out,.elf 以外<br>(例:ABC.x) | 指定したファイル名.elf<br>(例:ABC.x.elf) | 指定したファイル名<br>(例:ABC.x) |
| .out または .elf<br>(例:ABC.out) | 指定したファイル名<br>(例:ABC.out) | ファイル名の拡張子を.xにしたもの<br>(例:ABC.x) |
| 拡張子なし<br>(例:ABC) | 指定したファイル名<br>(例:ABC) | 指定したファイル名.x<br>(例:ABC.x) |

`-o` オプションを指定しなかった場合の出力ファイル名には `a.out` が使われます。このため、

* ELFファイル名は `a.out`
* X形式実行ファイル名は `a.x`

となります。

## リモートデバッガの利用

elf2x68k には m68k 用 GNU デバッガ `m68k-xelf-gdb` が含まれています。
デバッガからシリアルポートやネットワークを介して X68k 実機やエミュレータ上の [gdbserver-x68k](https://github.com/yunkya2/gdbserver-x68k) に接続することで、ツールチェインが出力するデバッグ情報を利用したリモートデバッグが可能です。

リモートデバッグの手順は gdbserver-x68k の[ドキュメント](https://github.com/yunkya2/gdbserver-x68k/blob/main/README.md) を参照してください。

## X-BASIC to C コンバータの利用

elf2x68k は `m68k-xelf-bas` コマンドによる X-BASIC プログラムのコンパイルが可能です。

```
usage: m68k-xelf-bas [OPTIONS][-o output] input.bas
```

`input.bas` で指定された X-BASIC プログラムを C ソースコードに変換し、そのファイルを m68k-xelf-gcc でコンパイルします。コンパイル時には XC の BASIC ライブラリ (libbas) が自動的にリンクされます。\
(`-specs=xc.specs -lbas` オプションがデフォルトで指定されます)

以下のコマンドラインオプション指定が可能です。
* `-o output` : 出力先となる X 形式実行ファイルのファイル名を指定します。省略した場合は入力ファイル名の拡張子を .bas から .x に変えたものになります。
* `-S`: X-BASIC から C への変換のみを行い、実行ファイルへのコンパイルは行いません。
* `-Xb [option]` : bas2c.py へ渡すオプションを指定します。

その他のオプションは、変換後に実行される `m68k-xelf-gcc` にそのまま渡されます。

X-BASIC から C への変換には [bas2c.py](https://github.com/yunkya2/bas2c-x68k) を使用しています。オプションの詳細については[こちらのドキュメント](https://github.com/yunkya2/bas2c-x68k/blob/main/README.md)も参照してください

実行例:
```
% cat test.bas                (X-BASIC プログラム)
10 for i=0 to 100
20 print i
30 next

% m68k-xelf-bas test.bas      (test.x と test.x.elf が生成される)

% m68k-xelf-bas -S test.bas   (test.c が生成される)

% cat test.c                  (変換された C ソースコード)
#include <basic0.h>
#include <string.h>

static int i;

/******** program start ********/
void main(int b_argc, char *b_argv[])
{
        b_init();
        for (i = 0; i <= 100; i++) {
                b_iprint(i);
                b_sprint(STRCRLF);
        }
        b_exit(0);
}
```

## ライブラリ環境の選択

elf2x68k は以下の 2 種類のライブラリ環境を用意しています。これらはコンパイル時の `-specs=` オプションによって使い分けが可能です。
  * [Newlib](https://sourceware.org/newlib/) (組み込みシステム等で使われている標準 C ライブラリ)
  * C Compiler PRO-68K v2.1 (XC) の 標準 C ライブラリ

### Newlib 環境

elf2x68k アーカイブに含まれている、標準のライブラリ環境です。C++ のコンパイルにも対応しています。

仕様が古く独自 API や 独自ヘッダファイルの多い XC 環境に比べると、glibc のような現在の標準的な C ライブラリに比較的近い仕様を持つので、既存のソフトウェアの移植などに向いています。

ソースコードの文字コードは UTF-8 がデフォルトとなっています。シフト JIS で書かれたソースコードを使用する場合はコンパイルオプションに `-finput-charset=cp932` を追加してください。
コンパイル後に出力されるバイナリに含まれる文字コードには、X68k 実機環境に合わせて常にシフト JIS が使われます。

#### specs ファイル指定

elf2x68k のデフォルトでは Newlib 環境のライブラリが使われます。追加の `-specs=` オプション指定により、以下のように動作が変わります。

* `-specs=nano.specs`\
機能縮小版ライブラリの Newlib-nano を使用します。
主に printf()/scanf() 系関数のフォーマット指定子による float/double の入出力機能を削除することなどにより、これらの機能が不要な場合にメモリ消費を削減できます。

* `-specs=c++small.specs`\
C++ プログラムのコンパイル、リンクで例外処理と RTTI (実行時型情報)を無効にします (-fno-exceptions -fno-rtti)。リンクで使用する 標準 C++ ライブラリにも、これらの機能を無効にしたものが使われます。
これらの機能には多くのメモリが必要なため、機能を無効にすることでメモリ消費を削減できます。

* `-specs=x68knodos.specs`\
Human68k DOS コール関連の機能を外したライブラリをリンクします。
標準出力、標準エラー出力への write() に IOCS _B_PUTC が使われる他、すべての入出力機能はエラーとなります。
ディスクのブートセクタから Human68k 抜きで起動するバイナリを開発できるようになります。

#### 標準 C ライブラリ仕様

Newlib で提供しているライブラリ関数の仕様は、以下のページを参照してください。

* [Red Hat newlib C Library Documentation](https://sourceware.org/newlib/libc.html)
* [Red Hat newlib C Math Library Documentation](https://sourceware.org/newlib/libm.html)

ファイル入出力では、Human68k の仕様にしたがってバイナリファイルとテキストファイルをサポートします。
* `open()` のオープンモードでは `O_BINRAY` (バイナリモード)と `O_TEXT` (テキストモード)を指定できます。
* `fopen()` などのオープンモードでは `"b"` (バイナリモード)と `"t"` (テキストモード)を指定できます。

どちらとも、指定がない場合にはテキストモードでオープンされます。

#### X68k 対応追加ライブラリ

Newlib のライブラリ関数に加えて、X68k 対応のために以下のライブラリを提供しています。

* libx68k  
Newlib のライブラリ関数が利用する、OS 依存のファイル入出力などのシステムコール関数 (open(), close(), read(), write() 等)を提供します。
* libx68kdos  
Human68k の DOS コールをサポートします。
ヘッダファイル `x68k/dos.h` を include することで利用できます。
* libx68kiocs  
X680x0 の IOCS コールをサポートします。
ヘッダファイル `x68k/iocs.h` を include することで利用できます。

これらのライブラリは、コンパイラドライバ `m68k-xelf-gcc` からリンクを行う際にデフォルトでリンクされます。

更に以下のライブラリを提供しています。

* libsocket  
(株)計測技研製 Human68k 用 TCP/IP ドライバを用いて、ソケット APIによるネットワーク処理を行うことができます。
詳しくは、[ソケットライブラリについて](README-socket.md) を参照してください。
* libpthread  
Human68k v2.0 以降で追加されたバックグラウンドプロセス機能を用いて、POSIX スレッド APIによるスレッド処理を行うことができます。
詳しくは、[POSIX スレッドライブラリについて](README-pthread.md) を参照してください。

#### XC 追加ライブラリ

elf2x68k のインストール時に `install-xclib.sh` で XC 環境をインストールすると、XC に含まれる以下のライブラリやヘッダファイルが Newlib 環境でも利用できるようになります。

* ライブラリ
  * DOSLIB.L (リンク時のコマンドラインに `-ldos` を指定)
  * IOCSLIB.L (リンク時のコマンドラインに `-liocs` を指定)
  * BASLIB.L (リンク時のコマンドラインに `-lbas` を指定)
* ヘッダファイル
  * doslib.h
  * iocslib.h
  * basic.h
  * basic0.h
  * audio.h
  * class.h
  * gpib.h
  * graph.h
  * image.h
  * mouse.h
  * music.h
  * music3.h
  * sprite.h
  * stick.h

#### スタックサイズ、ヒープサイズの指定

Newlib 環境でビルドされた実行ファイルは、スタックサイズ 32KB、ヒープサイズ初期値 64KB で実行されます。

(ヒープサイズは実行開始時の初期値です。実行中にヒープ領域が不足した場合、実行ファイルの存在するメモリブロックの後ろに空きがあれば自動的にメモリブロックを拡張します)

これらの値を変更したい場合は、ソースコード中で `_stack_size` , `_heap_size` というグローバル変数にそれぞれ以下のように値を設定してください。

```
int _stack_size = 128 * 1024;   // 128KB stack
int _heap_size = 256 * 1024;    // 256KB heap
```

### XC 環境

`install-xclib.sh` の実行によってインストールされるライブラリ環境で、C Compiler PRO-68K v2.1 (XC) に含まれているすべてのライブラリとヘッダファイルが利用できます。
X68k 実機の資産をそのままクロス開発環境に持ち込む際に向いています。

#### specs ファイル指定

XC の一部のヘッダファイルにはシフト JIS で日本語のコメントが含まれていますが、クロス開発環境でソースコードに UTF-8 を利用する場合を想定して、文字コードを UTF-8 に変換したものとシフト JIS のままのものの 2 種類がインストールされます。\
(コンパイル後に出力されるバイナリでは、ソースコードの文字コードに関わらず常にシフト JIS が使われます)

また、XC v2.1 では浮動小数点演算をどのように実行するかをライブラリによって切り替えるようになっていましたが (FLOATn.X 利用 / ソフトウェア処理 / コプロセッサ命令) これらをコンパイラオプションの `-specs=` 指定によって以下のように切り替えることができます。

| 浮動小数点演算処理     | ソースコードはUTF-8        | ソースコードはシフトJIS         |
|------------------------|----------------------------|---------------------------------|
| FLOATn.X を利用        | `-specs=xc.specs`          | `-specs=xc.sjis.specs`          |
| ソフトウェアで実行     | `-specs=xc.floateml.specs` | `-specs=xc.floateml.sjis.specs` |
| コプロセッサ命令で実行 | `-specs=xc.floatdrv.specs` | `-specs=xc.floatdrv.sjis.specs` |

例: シフトJISのソースコードを、浮動小数点演算をソフトウェア実行するようコンパイル
```
m68k-xelf-gcc -c -specs=xc.floateml.sjis.specs main.c
```
(分割コンパイルする際は、コンパイル、リンクのすべてのコマンドラインで同じ `-specs` 指定を行います)

#### ライブラリ指定

XC v2.1 の各ライブラリを使用するには、リンクの際のコマンドラインオプションに以下の指定を行います。

| ライブラリ | ライブラリオプション |
|------------|----------------------|
| DOSLIB.L   | -ldos                |
| IOCSLIB.L  | -liocs               |
| BASLIB.L   | -lbas                |

## x68k2elf.py スクリプト

X68k 標準のオブジェクトファイルやライブラリファイル (\*.o/\*.a/\*.l) は X68k 独自のファイル形式が用いられていますが、`x68k2elf.py` スクリプトでこれらを ELF オブジェクト/ライブラリファイルに変換できます。

バイナリ提供されているオブジェクトやライブラリをクロス開発環境上で使いたい場合は、このスクリプトで変換を行うことで `m68k-xelf-gcc` でのリンクが可能になります。

```
usage: x68k2elf.py [-h] [-k] [-v] infile [outfile]
```

* infile で指定した X68k オブジェクトファイルやライブラリファイルを ELF 形式に変換して outfile に出力します。
ライブラリファイルを指定した場合は、そのファイル内に含まれるオブジェクトファイルすべてを ELF 形式に変換し、それらをまとめたアーカイブファイル (*.a) を新規に作成します
* `-v` オプションで変換中のオブジェクトファイルの詳細を表示します。outfile を省略した場合はファイルの出力を行わないので、これと併用することで単にオブジェクトファイルの中を解析するのに使用できます
* ELF 変換の際、変換元のファイルのシンボル名は先頭のアンダーバー `'_'` が削除されます。
`-k` オプションを指定するとこの変換を行わず、C の関数名や変数名のシンボルはアンダーバーが付いたままになります

## ABI の差異について

アプリケーションバイナリが使用する関数の呼び出し規約やデータの配置方法といったインターフェース定義を ABI (Application Binary Interface) と呼びます。
複数のオブジェクトファイルやライブラリをリンクする際、すべてのファイルの ABI は一致している必要がありますが、XC 等 X68k の標準開発環境と 現在の m68k 向け gcc とでは ABI に違いがあります。

主な違いとしては、以下のような点があります。
* XC ABI
  * 関数呼び出しの前後では d0,d1,d2,a0,a1,a2 レジスタが破壊される
  * C 言語の関数名や変数名がアセンブラのシンボル名になる際、名前の先頭にアンダーバー `_` が付いたものが使われる
* gcc ABI
  * 関数呼び出しの前後では d0,d1,a0,a1 レジスタが破壊される (d2, a2 は保存される)
  * C 言語の関数名や変数名がアセンブラのシンボル名になる際は名前がそのまま使われる

elf2x68k では、gcc ABI をベースにしつつ XC のオブジェクトファイルやライブラリを利用できるようにするため、以下のような ABI を採用しています。

* elf2x68k ABI
  * 関数呼び出しの前後では d0,d1,d2,a0,a1,a2 レジスタが破壊される (XC ABI と同じ)
  * C 言語の関数名や変数名がアセンブラのシンボル名になる際は名前がそのまま使われる (gcc ABI と同じ)

C 言語のソースコードのみを普通にコンパイルする際は (Newlib 環境、XC 環境とも) この点については特に意識しないで良いのですが、過去のオブジェクトファイルの利用やアセンブラとの連携では以下の点に注意が必要です。

* elf2x68k 内での対応
  * C コンパイラ `m68k-xefl-gcc` 実行時は常にコンパイルオプション `-fcall-used-d2 -fcall-used-a2` を追加してコンパイルされます。これは gcc のデフォルトの specs ファイルを変更することで対応しているので、通常はユーザーがオプションの追加を意識する必要はありません
* XC 用資産への対応
  * XC 用のオブジェクトファイルやライブラリを `x68k2elf.py` で ELF オブジェクトに変換する際、シンボル名先頭のアンダーバー `_` を削除します
  * C 言語中に書かれたインラインアセンブラなど、XC ABI で書かれたものをソースコードのままクロス開発環境に持ち込む場合はアンダーバー削除の対象にならないため、ユーザが自分で削除する必要があります

## 謝辞

elf2x68k の開発には以下のソースコードを参考にさせていただきました。

* m68k クロスツールチェインのビルドスクリプトは、xdev68k 内のスクリプト [build_m68k-toolchain.sh](https://github.com/yosshin4004/xdev68k/blob/main/build_m68k-toolchain.sh) を元にしています。開発された よっしん氏 (@yosshin4004) に感謝いたします。
* Newlib の X68k 対応は、[newlib-1.19.0-human68k](https://github.com/Lydux/newlib-1.19.0-human68k) の [human68k対応コード](https://github.com/Lydux/newlib-1.19.0-human68k/tree/master/newlib/libc/sys/human68k) を元にしています。開発された Lyderic Maillet 氏 に感謝いたします。
* macOS ビルド対応については tantan さんの変更内容を参考にさせていただきました。感謝します。

## ライセンス

* src/*  
BSDライセンスが適用されます。
* scripts/*  
元となった xdev68k 内のスクリプト [build_m68k-toolchain.sh](https://github.com/yosshin4004/xdev68k/pblob/main/build_m68k-toolchain.sh) と同様に、Apache License Version 2.0 が適用されます。
* binutils, gcc, newlib  
それぞれの配布元が規定したライセンス条件が適用されます。アーカイブ内の COPYING ファイル等を参照してください。
