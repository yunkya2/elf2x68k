/*
 *  socket()
 */

#include "socket_internal.h"
#include "_at_exit.h"

uint32_t __sock_fds;
uint32_t __sock_connect_fds;
uint32_t __sock_listen_fds;
_ti_func __sock_func;

typedef struct usock
{
  int refcnt;
  char noblock;
  char type;
  int rdysock;
  void *p;
  char *name;
  int namelen;
  char *peername;
  int peernamelen;
  char errcodes[4];		/* Protocol-specific error codes */
  void *obuf;		/* Output buffer */
  void *ibuf;		/* Input buffer */
  char eol[3];		/* Text mode end-of-line sequence, if any */
  int flag;			/* Mode flags, defined in socket.h */
  int flush;			/* Character to trigger flush, if any */
  int event;
} usock;

/* 現在のソケットの状態を取得する */
char *__socket_sockstate(int sockfd)
{
    if (!__sock_func) {
        return NULL;
    }
    if (sockfd < 128 || sockfd >= 128 + 32) {
        return NULL;
    }
    return (char *)__sock_func(_TI_sockstate, (long *)sockfd);
}

/* ソケットのNONBLOCKフラグを変更する */
/* (inetd.x の struct usock 内を直接操作する) */
int __socket_nonblock(int sockfd, int nonblock)
{
    if (!__sock_func) {
        return -1;
    }
    if (sockfd < 128 || sockfd >= 128 + 32) {
        return -1;
    }
    struct usock *u = (struct usock *)__sock_func(_TI_sock_top, 0);
    if (u == 0) {
        return -1;
    }

    int res = u[sockfd - 128].noblock;
    if (nonblock >= 0) {
        u[sockfd - 128].noblock = nonblock;
    }
    return res;
}

static void socket_at_exit(int type)
{
    if (__sock_func == 0) {
        return;
    }

    for (int i = 31; i >= 0; i--) {
        if (__sock_fds & (1 << i)) {
        __sock_func(_TI_close_s, (long *)(128 + i));
        __sock_fds &= ~(1 << i);
        __sock_connect_fds &= ~(1 << i);
        __sock_listen_fds &= ~(1 << i);
        }
    }
}

/* プロセス終了時に実行するハンドラを登録する処理 */
/* (空の関数で上書きすることで、プロセス終了時にもソケットが開いたままになる) */
__attribute__((weak)) void __socket_register_at_exit(void)
{
    __at_exit(socket_at_exit);
}

static void socket_api_init(void)
{
    static int at_exit_registered = 0;

    if (at_exit_registered) {
        return;
    }
    at_exit_registered = 1;

    __sock_func = __sock_search_ti_entry();
    if (__sock_func == 0) {
        return;
    }
    __socket_register_at_exit();
}

int socket(int domain, int type, int protocol)
{
    socket_api_init();

    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[3];
    int res;

    arg[0] = domain;
    arg[1] = type & ~SOCK_NONBLOCK;
    arg[2] = protocol;

    res = __sock_func(_TI_socket, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    if (res >= 128 && res < 128 + 32) {
        __sock_fds |= (1 << (res - 128));
        if (type & SOCK_NONBLOCK) {
            __socket_nonblock(res, 1);
        }
    }
    return res;
}
