/*
 *  recv()
 */

#include "socket_internal.h"

ssize_t recv(int sockfd, void *buf, size_t len, int flags)
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

    res = __sock_func(_TI_recvfrom, arg);
    if (res < 0) {
        char *state = __socket_sockstate(sockfd);
        if (state) {
            errno = EAGAIN;
            return res;
        }
        errno = EIO;
        return res;
    }
    return res;
}
