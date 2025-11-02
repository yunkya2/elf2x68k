/*
 *  socket()
 */

#include <sys/socket.h>
#include <stdint.h>
#include <errno.h>
#include "tcpipdrv.h"
#include "_at_exit.h"

uint32_t __sock_fds;
_ti_func __sock_func;

static void socket_at_exit(int type)
{
    if (__sock_func == 0) {
        return;
    }

    for (int i = 31; i >= 0; i--) {
        if (__sock_fds & (1 << i)) {
        __sock_func(_TI_close_s, (long *)(128 + i));
        __sock_fds &= ~(1 << i);
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
    arg[1] = type;
    arg[2] = protocol;

    res = __sock_func(_TI_socket, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    if (res >= 128 && res < 128 + 32) {
        __sock_fds |= (1 << (res - 128));
    }
    return res;
}
