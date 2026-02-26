/*
 *  sendto()
 */

#include "socket_internal.h"

ssize_t sendto(int sockfd, const void *buf, size_t len, int flags, const struct sockaddr *src_addr, socklen_t addrlen)
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
    arg[4] = (long)src_addr;
    arg[5] = addrlen;

retry:
    res = __sock_func(_TI_sendto, arg);
    if (res < 0) {
        int stat = __socket_handle_send_result(sockfd);
        if (stat == 0) {
            goto retry;
        }
        errno = stat;
        return res;
    }
    return res;
}
