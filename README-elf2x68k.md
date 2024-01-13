# elf2x68k 補足ドキュメント

## ソースコードからのビルド

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

## X68k 対応ファイル

m68k-xelf/ 内に追加される、X68k 対応のためのファイル一覧です。

* bin/m68k-xelf-ld.x
  * GNUリンカ m68k-xelf-ld で生成したELFファイルから、elf2x68k.py スクリプトを用いてX形式のファイルを生成するスクリプトです
  * m68k-xelf-ld の代わりに使用することで m68k-xelf-gcc の出力結果として直接X形式ファイルが得られるようになります
* bin/elf2x68k.py
  * ELFファイルをX形式実行ファイルに変換するpythonスクリプトです
* bin/x68k2elf.py
  * X68kのオブジェクトファイルやライブラリをELF形式に変換するpythonスクリプトです
* lib/gcc/m68k-elf/\<gcc version\>/specs
  * m68k-xelf-gcc の挙動を修正するspecsファイルです。デフォルトの Newlib 環境時に使われます
    * リンク時にX68kに必要なライブラリもリンクします
    * リンカとして m68k-xelf-ld の代わりに上記 m68k-xelf-ld.x を使用します
* m68k-elf/lib/x68k.ld
  * X68k向けリンクの際に使用するリンカスクリプトです
* m68k-elf/lib/x68k{nodos,}.specs
  * m68k-elf-gcc の挙動を修正するspecsファイルです
    * x68k.specs は上記 lib/gcc/m68k-elf/specs と同じものです
    * x68knodos.specs はリンクされるライブラリからHuman68k関連のものを外してIOCSコールのみを利用可能にしてあるものです。ディスクのブートセクタからHuman68k抜きで起動するバイナリを開発できるようになります
* m68k-elf/lib/libx68k.a
  * newlibの下回りのシステムコール処理を提供するライブラリです
* m68k-elf/lib/libx68knodos.a
  * ilbx68k.aと同様ですがHuman68k関連のものを外したライブラリです。ファイルI/O関連はすべてエラーになり、コンソールへのwrite()のみがIOCS _B_PUTCとして処理されます
* m68k-elf/lib/libx68kiocs.a
* m68k-elf/lib/libx68kdos.a
  * IOCSコール、DOSコールを提供するライブラリです
* m68k-elf/lib/x68kcrt0.o
* m68k-elf/lib/x68kcrt0nodos.o
  * X68k用のC言語スタートアップ処理を行うオブジェクトファイルです。x68kcrt0nodos.o はコマンドライン引数の受け取りなどHuman68kに依存する処理を行いません
* m68k-elf/include/x68k/*
  * libiocs.a, libdos.a を利用するためのヘッダファイルです
* m68k-elf/sys-include/*
  * 標準ヘッダファイル m68k-elf/include 内を置き換えるためのヘッダファイルです。
  * fcntl.h に O_BINARY, O_TEXT の定義を追加するために使われます。
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

## サンプル

### sample/hello

* printf()とシンプルなIOCSコール呼び出しのサンプルです
* makeすると hello.x というファイルができます。Human68kでそのまま実行できます

### sample/hellosys

* 上記 sample/hello と同じ内容を、Human68k を使わずに実行するサンプルです
* makeすると hellosys.sys というバイナリが生成されます。このファイルは以下の手順で起動できます。
  1. 実機でフォーマット済みのフロッピーディスク、またはエミュレータでフォーマット済みディスクイメージを用意します
  2. hellosys.sys を **human.sys という名前で** ディスクにコピーします
      * ディスクには他のファイルを置かないでください。ブートセクタから起動できるファイルはディスクの連続したセクタに配置されている必要があるためです。
  3. 作成したディスク(イメージ)を実機またはエミュレータにセットし、リセットします。


### sample/fileio

* newlibのファイルI/O周りのAPIをテストするサンプルです
