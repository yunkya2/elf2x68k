/*
 *  accept()
 */

#include <sys/socket.h>
#include <stdint.h>
#include <errno.h>
#include "tcpipdrv.h"

extern uint32_t __sock_fds;

int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
    _ti_func func = _search_ti_entry();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[3];
    int res;

    arg[0] = sockfd;
    arg[1] = (long)addr;
    arg[2] = (long)addrlen;

    res = func(_TI_accept, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    if (res >= 128 && res < 128 + 32) {
        __sock_fds |= (1 << (res - 128));
    }
    return res;
}
