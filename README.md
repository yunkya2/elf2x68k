# elf2x68k

## 概要

PC環境のm68k用gccクロスツールチェインを用いてビルドされるELFファイルを、シャープ X680x0 用実行ファイル(X形式)に変換するpythonスクリプトです。

**本スクリプトは実験用です。** X68k用のクロス開発環境としては既に xdev68k (https://github.com/yosshin4004/xdev68k) が存在しますので、実用的な開発環境をお求めの方はこちらをご利用ください。

## インストール

動作はWindows11のWSL2にインストールしたUbuntu-20.04で確認しています。

xdev68kに含まれるm68k-elf-gccをツールチェインに使用します。
事前に xdev68k (https://github.com/yosshin4004/xdev68k) をインストールして環境変数 `XDEV68K_DIR` を設定し、更に `xdev68k/m68k-toolchain/bin` にパスを通しておく必要があります。

その後、

```
./install.sh
```

を実行すると、必要なスクリプト等を m68k-toolchain に追加します。

```
./uninstall.sh
```

を実行すると、インストール前の状態に戻します。

スクリプト自体は特にOSには依存しないので、他のUnix/Linux系環境でも問題なく動作すると思います。

## 実行方法

### GNUリンカ (m68k-elf-ld) への修正

* m68k-toolchain を用いてビルドを行うと、リンクの際にロードアドレスを変えたELFファイルを2つ生成し、それらから elf2x68k.py スクリプトを用いてX形式のファイルを生成するようになります。

### elf2x68k.py スクリプト

```
usage: elf2x68k.py [-h] [-o OUTPUT] [-b BASE] [-s] file1 [file2]
```

* file1, file2で指定したELFファイルを元にX形式に変換します。
* 変換後のファイルは　`-o` オプションが指定されていればそのファイル名で、オプションが省略されている場合は file1 に '.x' を追加したファイル名で作成されます。
* file1, file2はスタティックリンクされた、m68kアーキテクチャ用ELF実行ファイルである必要があります。
  * file1のみが指定されている場合は、与えられたELFファイルをロード先アドレス固定X形式(Human.sysで使われている形式)に変換します。
  * file1, file2が指定されている場合は、2つのELFファイルの差分を利用することで再配置情報を生成し、変換後のX形式ファイルに付加します。これによりHuman68kから実行可能なファイルになります。正しく再配置情報を生成するためには、2つのファイルはロード先アドレス以外の内容がすべて等しいELFファイルである必要があります。
* `-b` オプションが指定されている場合は、変換後のX形式ファイルのベースアドレスが指定したアドレスに設定されます。
  * X68kのディスクのブートセクタから起動可能なファイルを生成するためには、`-b 0x6800`　を指定してベースアドレスを0x6800にしておく必要があります。
* 変換元のELFファイルにシンボル情報がある場合は、X形式ファイルにもその情報が付加されます。 `-s` オプションが指定されている場合はシンボル情報を削除します。

## サンプル

elf2x68k を用いてX形式に変換できるサンプルコードを用意しています。

xdev68kに含まれるm68k用newlibをサポートしてみました。システムコール関数をHuman68kのDOSコールに繋いだり、ヒープ領域のサポートを追加したりしています。
printf()程度は動作するようですが、まだ色々不完全な部分が残っているようです。

### sample/hellosys

* ロード先アドレス固定のX形式ファイルを作成するサンプルです。
* makeすると hellosys.sys というバイナリが生成されます。このファイルは以下の手順で起動できます。
  1. 実機でフォーマット済みのフロッピーディスク、またはエミュレータでフォーマット済みディスクイメージを用意します
  2. hellosys.sys を **human.sys という名前で** ディスクにコピーします
      * ディスクには他のファイルを置かないでください。ブートセクタから起動できるファイルはディスクの連続したセクタに配置されている必要があるためです。
  3. 作成したディスク(イメージ)を実機またはエミュレータにセットし、リセットします。

### sample/hellox

* 通常のX形式ファイルを生成するサンプルです。
* makeすると hellox.x というファイルができます。Human68kでそのまま実行できます。

### sample/hellostdc

* newlibの標準Cライブラリ関数をテストします。
* Human68kのDOSコールを適当に繋いだだけなので、まだ動作が不完全です。

## ライセンス

elf2x68k はBSDライセンスとします


