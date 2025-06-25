/*
 *  recv()
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

ssize_t recv(int sockfd, void *buf, size_t len, int flags)
{
    _ti_func func = _search_ti_entry();

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
    arg[4] = 0;
    arg[5] = 0;

    res = func(_TI_recvfrom, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    return res;
}
