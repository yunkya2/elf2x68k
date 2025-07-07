/*
 *  setsockopt()
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen)
{
    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[2];
    int res;

    switch (optname) {
    case SO_SOCKMODE:
        arg[0] = sockfd;
        arg[1] = *(const int *)optval;
        res = __sock_func(_TI_sockmode, arg);
        if (res < 0) {
            errno = EBADF;
            return -1;
        }
        return 0;

    case SO_SOCKKICK:
    case SO_SOCKFLUSH:
        res = __sock_func(optname == SO_SOCKKICK ? _TI_sockkick : _TI_usflush,
                   (long *)sockfd);
        if (res < 0) {
            errno = EBADF;
            return -1;
        }
        return 0;

    default:
        errno = EINVAL;
        return -1;
    }
}
