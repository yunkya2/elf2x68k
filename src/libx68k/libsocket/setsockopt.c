/*
 *  setsockopt()
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen)
{
    _ti_func func = __sock_search_ti_entry();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[2];
    int res;

    switch (optname) {
    case SO_SOCKMODE:
        if (optlen != sizeof(int)) {
            errno = EINVAL;
            return -1;
        }
        arg[0] = sockfd;
        arg[1] = *(const int *)optval;
        res = func(_TI_sockmode, arg);
        if (res < 0) {
            errno = EBADF;
            return -1;
        }
        return 0;

    case SO_SOCKKICK:
    case SO_SOCKFLUSH:
        if (optlen != 0) {
            errno = EINVAL;
            return -1;
        }
        res = func(optname == SO_SOCKKICK ? _TI_sockkick : _TI_usflush,
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
