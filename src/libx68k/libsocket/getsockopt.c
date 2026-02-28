/*
 *  getsockopt()
 */

#include "socket_internal.h"

int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen)
{
    _ti_func func = __sock_search_ti_entry();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[2];
    int res;
    char *resc;

    switch (optname) {
    case SO_REUSEADDR:
    case SO_BROADCAST:
        *(int *)optval = 1;
        return 0;

    case SO_ERROR:
        int res = __socket_connect_confirm(sockfd);
        if (res == EBADF) {
            errno = EBADF;
            return -1;
        }
        if (res >= 0) {
            __sock_errno = res;
        }
        *(int *)optval = __sock_errno;
        return 0;

    case SO_ACCEPTCONN:
        if (sockfd >= 128 && sockfd < 128 + 32) {
            *(int *)optval = (__sock_listen_fds & (1 << (sockfd - 128))) ? 1 : 0;
            return 0;
        } else {
            errno = EBADF;
            return -1;
        }

    case SO_GETVERSION:
        res = func(_TI_get_version, NULL);
        if (res < 0) {
            errno = EBADF;
            return -1;
        }
        *(int *)optval = res;
        return 0;

    case SO_SOCKMODE:
        arg[0] = sockfd;
        arg[1] = SOCK_QUERY;
        res = func(_TI_sockmode, arg);
        if (res < 0) {
            errno = EBADF;
            return -1;
        }
        *(int *)optval = res;
        return 0;

    case SO_SOCKLENRECV:
    case SO_SOCKLENSEND:
        arg[0] = sockfd;
        arg[1] = optname - SO_SOCKLENRECV; // 0 for SO_SOCKLENRECV, 1 for SO_SOCKLENSEND
        res = func(_TI_socklen, arg);
        if (res < 0) {
            errno = EBADF;
            return -1;
        }
        *(int *)optval = res;
        return 0;

    case SO_SOCKERR:
    case SO_SOCKSTATE:
        if (*optlen <= 0) {
            errno = EINVAL;
            return -1;
        }
        resc = (char *)func(optname == SO_SOCKERR ? _TI_sockerr : _TI_sockstate,
                            (long *)sockfd);
        if (resc == NULL) {
            errno = EBADF;
            return -1;
        }
        strncpy((char *)optval, resc, *optlen - 1);
        ((char *)optval)[*optlen - 1] = '\0'; // Ensure null termination
        *optlen = strlen((char *)optval);
        return 0;

    case SO_NONBLOCK:
        *(int *)optval = __socket_nonblock(sockfd, -1);
        return 0;

    default:
        errno = EINVAL;
        return -1;
    }
}
