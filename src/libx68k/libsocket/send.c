/*
 *  send()
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

ssize_t send(int sockfd, const void *buf, size_t len, int flags)
{
    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[6];
    ssize_t res;

    arg[0] = sockfd;
    arg[1] = (long)buf;
    arg[2] = len;
    arg[3] = flags;
    arg[4] = 0;
    arg[5] = 0;

    res = __sock_func(_TI_sendto, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    return res;
}
