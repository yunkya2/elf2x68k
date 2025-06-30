/*
 *  socket()
 */

#include <sys/socket.h>
#include <stdint.h>
#include <errno.h>
#include "tcpipdrv.h"

extern uint32_t __sock_fds;

int socket(int domain, int type, int protocol)
{
    _ti_func func = __sock_search_ti_entry ();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[3];
    int res;

    arg[0] = domain;
    arg[1] = type;
    arg[2] = protocol;

    res = func(_TI_socket, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    if (res >= 128 && res < 128 + 32) {
        __sock_fds |= (1 << (res - 128));
    }
    return res;
}
