/*
 *  sendto()
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

ssize_t sendto(int sockfd, const void *buf, size_t len, int flags, const struct sockaddr *src_addr, socklen_t addrlen)
{
    _ti_func func = __sock_search_ti_entry();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[6];
    ssize_t res;

    arg[0] = sockfd;
    arg[1] = (long)buf;
    arg[2] = len;
    arg[3] = flags;
    arg[4] = (long)src_addr;
    arg[5] = addrlen;

    res = func(_TI_sendto, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    return res;
}
