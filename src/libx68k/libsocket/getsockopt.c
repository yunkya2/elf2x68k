/*
 *  getsockopt()
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <errno.h>
#include "tcpipdrv.h"

int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen)
{
    _ti_func func = _search_ti_entry();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[2];
    int res;
    char *resc;

    switch (optname) {
    case SO_GETVERSION:
        if (*optlen != sizeof(int)) {
            errno = EINVAL;
            return -1;
        }
        res = func(_TI_get_version, NULL);
        if (res < 0) {
            errno = EBADF;
            return -1;
        }
        *(int *)optval = res;
        return 0;

    case SO_SOCKMODE:
        if (*optlen != sizeof(int)) {
            errno = EINVAL;
            return -1;
        }
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
        if (*optlen != sizeof(int)) {
            errno = EINVAL;
            return -1;
        }
        arg[0] = sockfd;
        arg[1] = optname - SO_SOCKLENRECV; // 0 for SO_SOCKLENRECV, 1 for SO_SOCKLENSEND
        res = func(_TI_sockmode, arg);
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

    default:
        errno = EINVAL;
        return -1;
    }
}
