# elf2x68k ソケットライブラリについて

## 概要

elf2x68k はソケット API によるネットワーク処理を行うソケットライブラリ libsocket を提供しています。Newlib環境でのみ使用できます。

## 動作環境

ソケットライブラリを利用するためには、
http://retropc.net/x68000/software/internet/kg/tcppacka/
で無償配布されている (株)計測技研製 Human68k 用 TCP/IP ドライバと、このドライバに対応したネットワークアダプタ、およびそのドライバが必要になります。以下のようなネットワークアダプタが利用できます(動作は ZUSB のみで確認)。

  * X680x0 実機向け: Neptune-X, Nereid, RaSCSI 等
  * X68000 Z 向け: [ZUSB](https://github.com/yunkya2/x68kz-zusb) ([zusbether](https://github.com/yunkya2/x68kz-zusb/blob/master/zusbether/README.md)) + BUFFALO LUA3-U2_ATX

ソケットライブラリの使用前に、利用するネットワークアダプタ用ドライバのドキュメントに従って設定を行い、TCPPACKA 付属のコマンドでネットワーク接続ができることを確認してください。

## 使用方法

ソケットライブラリは elf2x68k 配布ファイル内に libsocket.a として含まれています。  
ソケット API を用いたプログラムのリンクの際に `m68k-xelf-gcc` のコマンドラインに `-lsocket` オプションを追加することで使用できます。

例:
```
m68k-xelf-gcc -o network.x network.c -lsocket
```

## 提供 API

ソケットライブラリでは、POSIX ソケット API におおむね準拠した以下の API を用いることができます。

### ヘッダファイル

以下のヘッダファイルが使用できます。

  * <sys/socket.h>
  * <netinet/in.h>
  * <arpa/inet.h>
  * <netdb.h>

### ソケット API

#### <sys/socket.h> - ソケット操作
  * int **accept**(int *sockfd*, struct sockaddr \**addr*, socklen_t \**addrlen*);
  * int **bind**(int *sockfd*, const struct sockaddr \**addr*, socklen_t *addrlen*);
  * int **connect**(int *sockfd*, const struct sockaddr \**addr*, socklen_t *addrlen*);
  * int **listen**(int *sockfd*, int *backlog*);
  * int **socket**(int *domain*, int *type*, int *protocol*);
  * int **getsockname**(int *sockfd*, struct sockaddr \**addr*, socklen_t \**addrlen*);
  * int **getpeername**(int *sockfd*, struct sockaddr \**addr*, socklen_t \**addrlen*);
  * int **shutdown**(int *sockfd*, int *how*);
  * ssize_t **recv**(int *sockfd*, void \**buf*, size_t *len*, int *flags*);
  * ssize_t **recvfrom**(int *sockfd*, void \**buf*, size_t *len*, int *flags*, struct sockaddr \**src_addr*, socklen_t \**addrlen*);
  * ssize_t **send**(int *sockfd*, const void \**buf*, size_t *len*, int *flags*);
  * ssize_t **sendto**(int *sockfd*, const void \**buf*, size_t *len*, int *flags*, const struct sockaddr \**dest_addr*, socklen_t *addrlen*);

以下の関数は、引数に socket() や accept() の返すファイルディスクリプタを渡すことでソケットに対する操作に使用することができます。

  * ssize_t **read**(int *fd*, void \**buf*, size_t *count*);
  * ssize_t **write**(int *fd*, const void \**buf*, size_t *count*);
  * int **close**(int *fd*);

以下の関数は、計測技研 TCP/IP ドライバの独自仕様 API を呼び出すために使用します。  
(SO_LINGER や SO_KEEPALIVE などの通常の POSIX ソケット API で設定するオプションは、計測技研 TCP/IP ドライバにその機能がないため使用できません)

  * int **getsockopt**(int *sockfd*, int *level*, int *optname*, void \**optval*, socklen_t \**optlen*);
  * int **setsockopt**(int *sockfd*, int *level*, int *optname*, const void \**optval*, socklen_t *optlen*);
    * ファイルディスクリプタ sockfd で指定したソケットに関するオプションを操作します。setsockopt() で値を設定し、getsockopt() で現在の設定値を取得します。
    * level 引数は使用しません。何を指定しても無視されます。
    * optname 引数にはオプションを指定する以下の値のいずれかを指定します。
    * **SO_GETVERSION** (getのみ)
      * TCP/IP ドライバのバージョンを取得します。getsockopt() のみで指定できます。
      * optval 引数にバージョン番号を返す int 型変数へのポインタを渡します。
      * sockfd 引数は無視されます。ソケットをオープンしなくても呼び出し可能です。
      * (計測技研ライブラリの _get_version() 相当)
    * **SO_SOCKMODE** (get/set)
      * sockfd のソケットのバイナリ/アスキーモードを設定します。
      * optval 引数にはモードを格納する int 型変数へのポインタを渡します。setsockopt() でモードを変数の値に設定し、getsockopt() で現在の設定値を変数に返します。以下の値を使用します。
        * **SOCK_BINARY** - バイナリモード　(改行コードの変換を行わない)
        * **SOCK_ASCII** - ASCIIモード (改行コードの変換を行う)
      * (計測技研ライブラリの sockmode() 相当)
    * **SO_SOCKLENRECV** (getのみ)
    * **SO_SOCKLENSEND** (getのみ)
      * sockfd のソケットの受信バッファ(SO_SOCKLENRECV)/送信バッファ(SO_SOCKLENSEND)に残っているデータの量を取得します。getsockopt() のみで指定できます。
      * optval 引数にデータ量を返す int 型変数へのポインタを渡します。
      * (計測技研ライブラリの socklen() 相当)
    * **SO_SOCKKICK** (setのみ)
      * sockfd のソケットが stream type の場合に、強制的にデータを再送します。setsockopt() のみで指定できます。
      * optval, optlen 引数は使用しません。
      * (計測技研ライブラリの sockkick() 相当)
    * **SO_SOCKFLUSH** (setのみ)
      * sockfd のソケットが stream type の場合に、送信バッファをフラッシュします。setsockopt() のみで指定できます。
      * optval, optlen 引数は使用しません。
      * (計測技研ライブラリの usflush() 相当)
    * **SO_SOCKERR** (getのみ)
      * sockfd のソケットで最後に起きたエラーを表す文字列を返します。getsockopt() のみで指定できます。
      * optval 引数には文字列を取得するバッファへのポインタを指定します。
      * optlen 引数にはバッファサイズを格納した socklen_t 型変数へのポインタを渡します。取得後に、変数に実際に取得できた文字列の長さが返されます。
      * (計測技研ライブラリの sockerr() 相当)
    * **SO_SOCKSTATE** (getのみ)
      * sockfd のソケットが stream type の場合に、ソケットの状態を表す文字列を返します。getsockopt() のみで指定できます。
      * optval 引数には文字列を取得するバッファへのポインタを指定します。
      * optlen 引数にはバッファサイズを格納した socklen_t 型変数へのポインタを渡します。取得後に、変数に実際に取得できた文字列の長さが返されます。
      * (計測技研ライブラリの sockstate() 相当)

#### <arpa/inet.h> - インターネットアドレス操作

  * in_addr_t **inet_addr**(const char \**cp*);
  * int **inet_aton**(const char \**cp*, struct in_addr \**inp*);
  * int **inet_pton**(int *af*, const char \**src*, void \**dst*);
  * char \***inet_ntoa**(struct in_addr *in*);
  * const char \***inet_ntop**(int *af*, const void \**src*, char \**dst*, socklen_t *size*);

#### <netinet/in.h> - インターネットプロトコルファミリー定義

  * **htonl**(*x*)
  * **htons**(*x*)
  * **ntohl**(*x*)
  * **ntohs**(*x*)

#### <netdb.h> - ネットワークデータベース操作

  * struct hostent \***gethostbyname**(const char \**name*);
  * struct hostent \***gethostbyaddr**(const char \**addr*, socklen_t *len*, int *type*);
  * struct netent \***getnetbyname**(const char \**name*);
  * struct netent \***getnetbyaddr**(unsigned long *net*, int *type*);
  * struct servent \***getservbyname**(const char \**name*, const char \**proto*);
  * struct servent \***getservbyport**(int *port*, const char \**proto*);
  * struct protoent \***getprotobyname**(const char \**name*);
  * struct protoent \***getprotobynumber**(int *proto*);
  * int **getaddrinfo**(const char \**node*, const char \*\**service*, const struct addrinfo \**hints*, struct addrinfo \*\**res*);
  * void **freeaddrinfo**(struct addrinfo \**res*);

## 仕様と制約事項

* TCP/IP ドライバが常駐していないなどネットワーク接続ができない状態の場合は、ソケット API は errno に ENOSYS を設定してエラーで終了します。
* 本ライブラリで使用できるアドレスファミリ、タイプは AF_INET (IPv4 インターネット)、SOCK_STREAM (TCP)、SOCK_DGRAM (UDP) のみです。IPv6 や SOCK_RAW (raw ソケット) などは未対応です。
* <sys/socket.h> で宣言されているソケット API は、エラーの際は関数の戻り値で -1 を返してエラー要因に応じた値を errno 変数に格納するのが本来の仕様です。ところが、計測技研 TCP/IP ドライバはエラー発生の際に呼び出し元アプリケーションに errno を返す手段が存在しないようです。
このため、elf2x68k libsocket のソケット API はエラー発生時にその要因に関わらず常に errno に EIO (I/Oエラー) を設定します。
* ソケットを用いたプログラムがソケットをクローズせずに終了した場合にも正しくクローズ処理が行われるようにするため、socket() 関数を初めて呼び出す際にそのプロセスの終了/CTRL+C/エラー時の処理アドレス(DOS _EXITVC/_CTRLCVC/_ERRJVC)を変更します。プログラムの方でこれらのベクタを上書きすると終了時のクローズ処理が行われずソケットが開きっぱなしになってしまうため、ベクタを変更する際は処理後に変更前のベクタアドレスに戻るようにしてください。

## ライブラリの実装とソースコードについて

ソケットライブラリ libsocket の実装では、(株) 計測技研 が開発し、
http://retropc.net/x68000/software/internet/kg/tcppackb/
にて無償配布されている「TCP/IPドライバ無償配布パッケージ(B PACK)」を参考にしています。

ソースコード

- gethostnamadr.c
- search_ti_entry.c
- network.h
- tcpipdrv.h

については、配布パッケージに含まれるソースコードを改変したものを使用しています。
オリジナルのパッケージの配布条件にあるソースコード改変時の記述、
```
    ・ソースファイルに手を加えて配布を行いたい場合、アーカイブされた本
      パッケージとは別にpatch形式などの差分ファイルを添付する形で行って
      ください。
```
に従い、リポジトリにはアーカイブされたパッケージ TCPPACKB.LZH と差分ファイル [tcppack.patch](tcppack.patch) の形で収録しています。

以下に、パッケージ内の README_B.doc に記載されている、サポートと配布条件に関する記述を転記します。
(既に存在しないパソコン通信ホストに関する記述は削除しています)

```
SUPPORT

    本パッケージに含まれるソフトウェアは完全に無保証です。本パッケージ
    を使用した／しなかったことにより発生した不利益等に関しては、（株）
    計測技研は一切関知いたしません。
    また、（株）計測技研は原則としてサポートを行いません。使用方法等に
    に関するお問いあわせ、技術的内容についてのご質問等にはお答えできま
    せんのでご了承ください。
    各種ドライバとあわせてお使いいただいた際の不具合等につきましては、
    ドライバの供給もとにお問い合わせください。


DISTRIBUTION

    本パッケージの著作権は（株）計測技研が保有いたします。
    本パッケージはフリーソフトウェアとして公開いたします。本パッケージ
    は無料で入手し、無料で使用することができます。
    本パッケージは著作権保有者の許可なくコピー、転載することが可能です
    が、以下の点にご留意ください。

    ・パッケージに含まれるファイルの一切の改変を禁止します。
    ・パッケージを配布する際は、パッケージに含まれるすべてのファイルを
      配布するものとし、ファイル数の増減は認めません。
    ・パッケージはできるだけアーカイブされた状態で配布してください。ド
      ライバ等と同時に配布する際に、パッケージに含まれるものとそうでな
      いものを区別できるようにするためです。
    ・ソースファイルに手を加えて配布を行いたい場合、アーカイブされた本
      パッケージとは別にpatch形式などの差分ファイルを添付する形で行って
      ください。
    ・本パッケージを使用、または参考にして作成したソフトウェアは、自由
      に配布することができます。

　　以下に示すケースでは、必ず（株）計測技研までご連絡ください。

    ・雑誌メディア等で本パッケージを紹介する場合。
    ・商用ソフトウェアで本パッケージの一部またはすべてを使用する場合。
```
