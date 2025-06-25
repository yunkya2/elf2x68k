/*
 *  bind()
 */

#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
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
    arg[2] = addrlen;

    res = func(_TI_bind, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    return res;
}
