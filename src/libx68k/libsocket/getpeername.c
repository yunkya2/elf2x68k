/*
 *  getpeername()
 */

#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

int getpeername(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[3];
    int res;

    arg[0] = sockfd;
    arg[1] = (long)addr;
    arg[2] = (long)addrlen;

    res = __sock_func(_TI_getpeername, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    return res;
}
