# elf2x68k 補足ドキュメント

## ソースコードからのビルド

* elf2x68k は、x86_64 Linux、MSYS2 MinGW 64bit、macOS (Apple Silicon) 上でビルドすることができます。
* 他の環境でビルドを行ってみた例もありますので、以下のリンクも参考にしてみてください。
  * Cygwin (Makoto Kamada さん)
    * https://x.com/kamadox/status/1802555953600213313
* [Releases](https://github.com/yunkya2/elf2x68k/releases) にはバイナリリリースとともにソースコードの tarball が置かれていますが、ビルドの際は基本的には git リポジトリから clone してビルドすることを推奨します。
* elf2x68k は複数の git のサブモジュールを含んでいるため、git clone 時には `--recursive` オプションを指定して以下のように行ってください。
  ```
  git clone --recursive https://github.com/yunkya2/elf2x68k.git
  ```
  * `--recursive` を付けずに clone してしまった場合は、後から `git submodule update --init` を実行することでもサブモジュールを取得できます。
* ソースコードの clone 後、
  ```
  make all
  ```
  で、必要なファイルをダウンロードしてビルドしたツールチェインと X68k 対応ファイルを `m68k-xelf` にインストールします。バイナリ配布同様に、`m68k-xelf/bin` にパスを通すと使用できるようになります。
* その他、Makefile で以下のターゲットを指定することができます。
  ```
  make simple       - シンプル環境 (C++、newlib-nano、gdb無し) のビルドを行います
  make mingw        - MinGW 向けバイナリを Linux 環境でビルドします
  make mingw-simple - mingw + simple の組み合わせでビルドします
  make m68k-xelf    - m68k-xelf ツールチェインのビルドのみを行います
  make download     - ツールチェインビルドに必要なファイルのダウンロードのみを行います
  make install      - m68k-xelf に X68k 対応ファイルのインストールのみ行います
  make uninstall    - m68k-xelf の X68k 対応ファイルを削除します
  make clean        - ビルドの生成物を削除します (ダウンロードしたアーカイブは削除しません)
  make pristine     - ダウンロードアーカイブも含めて削除
  make help         - 指定可能なターゲットを表示します
  ```

### MinGW 向けバイナリのクロスビルドについて

`make mingw` では、MinGW クロスコンパイラを用いて Linux 環境上で MinGW 向けのバイナリをビルドすることができます。
クロスビルドを行うためには、以下の準備が必要です (Ubuntu 24.04LTS で確認)。

1. MinGW クロスコンパイラと MinGW 用 zlib をインストールします。
    ```
    sudo apt install mingw-w64 libz-mingw-w64-dev
    ```
2. gcc のビルドに libiconv が必要ですが、Ubuntu のパッケージには MinGW 用の libiconv が無いため、ソースコードからビルドしてインストールします。
    ```
    wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.18.tar.gz
    tar zxvf libiconv-1.18.tar.gz
    cd libiconv-1.18
    ./configure --host=x86_64-w64-mingw32 --prefix=/usr/x86_64-w64-mingw32 --enable-shared --disable-static
    make
    sudo make install
    ```

ビルドの際には、ライブラリのコンパイルのため Linux ネイティブの m68k-xelf ツールチェインも必要となります。そのため、`make mingw` を実行すると、まず `make m68k-xelf` でツールチェインをビルドしてから MinGW 向けバイナリのビルドが行われます。

## X68k 対応ファイル

m68k-xelf/ 内に追加される、X68k 対応のためのファイル一覧です。

* bin/m68k-xelf-ld.x
  * GNUリンカ m68k-xelf-ld で生成したELFファイルから、elf2x68k.py スクリプトを用いてX形式のファイルを生成するスクリプトです
  * m68k-xelf-ld の代わりに使用することで m68k-xelf-gcc の出力結果として直接X形式ファイルが得られるようになります
* bin/elf2x68k.py
  * ELFファイルをX形式実行ファイルに変換するpythonスクリプトです
* bin/x68k2elf.py
  * X68kのオブジェクトファイルやライブラリをELF形式に変換するpythonスクリプトです
* bin/bas2c.py
* bin/bas2c.def
  * [X-BASIC to Cコンバータ](https://github.com/yunkya2/bas2c-x68k) の python スクリプトです
* bin/m68k-xelf-bas
  * bas2c.py を用いて X-BASIC プログラムを C に変換し、m68k-xelf-gcc でコンパイルするスクリプトです
* bin/m68k-xelf-gdb
  * GDB (m68k-elf-gdb) で [XEiJ](https://stdkmd.net/xeij) の提供する TCP/IP ポートに接続してリモートデバッグを行うスクリプトです
* bin/unlha.py
  * [LZH アーカイブ展開ツール](https://github.com/yunkya2/unlha) の python スクリプトです
* lib/gcc/m68k-elf/\<gcc version\>/specs
  * m68k-xelf-gcc の挙動を修正するspecsファイルです。デフォルトの Newlib 環境時に使われます
    * リンク時にX68kに必要なライブラリもリンクします
    * リンカとして m68k-xelf-ld の代わりに上記 m68k-xelf-ld.x を使用します
* m68k-elf/lib/x68k.ld
  * X68k向けリンクの際に使用するリンカスクリプトです
* m68k-elf/lib/x68k{nodos,}.specs
* m68k-elf/lib/nano.specs
* m68k-elf/lib/c++small.specs
  * m68k-elf-gcc の挙動を修正するspecsファイルです
    * x68k.specs は上記 lib/gcc/m68k-elf/specs と同じものです
    * x68knodos.specs はリンクされるライブラリからHuman68k関連のものを外してIOCSコールのみを利用可能にしてあるものです。ディスクのブートセクタからHuman68k抜きで起動するバイナリを開発できるようになります
    * nano.specs は標準Cライブラリとして libc.a の代わりに libc-nano.a をリンクします。printf() などに軽量版を用いた Newlib-nano を使用します
    * c++small.specs はC++プログラムのコンパイル、リンクで例外処理とRTTIを無効にします (-fno-exceptions -fno-rtti)。リンクで使用するC++標準ライブラリもこれらの機能を無効にしたものが使われます。
* m68k-elf/lib/libx68k.a
  * newlibの下回りのシステムコール処理を提供するライブラリです
* m68k-elf/lib/libx68knodos.a
  * ilbx68k.aと同様ですがHuman68k関連のものを外したライブラリです。ファイルI/O関連はすべてエラーになり、コンソールへのwrite()のみがIOCS _B_PUTCとして処理されます
* m68k-elf/lib/libx68kiocs.a
* m68k-elf/lib/libx68kdos.a
  * IOCSコール、DOSコールを提供するライブラリです
* m68k-elf/lib/libsocket.a
* m68k-elf/lib/libpthread.a
  * ソケットAPI、POSIXスレッドAPIを提供するライブラリです
* m68k-elf/lib/x68kcrt0.o
* m68k-elf/lib/x68kcrt0nodos.o
  * X68k用のC言語スタートアップ処理を行うオブジェクトファイルです。x68kcrt0nodos.o はコマンドライン引数の受け取りなどHuman68kに依存する処理を行いません
* m68k-elf/include/x68k/*
  * libiocs.a, libdos.a を利用するためのヘッダファイルです
* m68k-elf/sys-include/*
  * 標準ヘッダファイル m68k-elf/include 内を置き換えるためのヘッダファイルです
  * fcntl.h に O_BINARY, O_TEXT の定義を追加するために使われます
  * dirent.h に DIR, struct dirent の定義を追加するために使われます
  * ソケットAPI、POSIXスレッドAPIのためのヘッダファイルを追加するために使われます
* install-xclib.sh
  * [無償公開されている C Compiler PRO-68K v2.1 (XC)](http://retropc.net/x68000/software/sharp/xc21/) をダウンロードし、ライブラリとヘッダファイルをインストールして XC 環境を構築するスクリプトです。

## elf2x68k.py スクリプト

```
usage: elf2x68k.py [-h] [-o OUTPUT] [-b BASE] [-s] file
```

* fileで指定したELF実行ファイルをX形式に変換します。
* 変換後のファイルは　`-o` オプションが指定されていればそのファイル名で、オプションが省略されている場合は file に '.x' を追加したファイル名で作成されます。
* file は再配置情報を残したままスタティックリンクされた、m68kアーキテクチャ用ELF実行ファイルである必要があります。
  * スタティックリンクの際、リンカに `-q` オプションを与えることでELF実行ファイルにも再配置情報を残しておきます。
* `-b` オプションが指定されている場合は、変換後のX形式ファイルのベースアドレスが指定したアドレスに設定されます。
  * X68kのディスクのブートセクタから起動可能なファイルを生成するためには、`-b 0x6800`　を指定してベースアドレスを0x6800にしておく必要があります。
* 変換元のELFファイルのシンボル情報がX形式ファイルにも付加されます。 `-s` オプションが指定されている場合はシンボル情報を削除します。
