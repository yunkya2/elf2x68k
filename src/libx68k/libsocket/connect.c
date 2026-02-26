/*
 *  connect()
 */

#include "socket_internal.h"

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[3];
    int res;

    arg[0] = sockfd;
    arg[1] = (long)addr;
    arg[2] = addrlen;

    res = __sock_func(_TI_connect, arg);
    if (res < 0) {
        char *state = __socket_sockstate(sockfd);
        if (state && (*state == 'S' || *state == 'E')) {   // SYN SENT or ESTABLISHED
            __sock_connect_fds |= (1 << (sockfd - 128));
            errno = EINPROGRESS;
            return res;
        }
        errno = EIO;
        return res;
    }
    return res;
}
