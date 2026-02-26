/*
 *  accept()
 */

#include "socket_internal.h"

static int accept_fd = -1;
static struct sockaddr accept_addr;

int __socket_push_accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
    accept_fd = sockfd;
    accept_addr = *addr;
    return 0;
}

static int __socket_pop_accept(struct sockaddr *addr, socklen_t *addrlen)
{
    if (accept_fd < 0) {
        return -1;
    } else {
        int fd = accept_fd;
        accept_fd = -1;
        if (addr && addrlen) {
            socklen_t copy_len = (*addrlen < sizeof(accept_addr)) ? *addrlen : sizeof(accept_addr);
            memcpy(addr, &accept_addr, copy_len);
            *addrlen = copy_len;
        }
        return fd;
    }
}

int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[3];
    int res;

    res = __socket_pop_accept(addr, addrlen);
    if (res >= 0) {
        return res;
    }

    arg[0] = sockfd;
    arg[1] = (long)addr;
    arg[2] = (long)addrlen;

    res = __sock_func(_TI_accept, arg);
    if (res < 0) {
        char *state = __socket_sockstate(sockfd);
        if (state && *state == 'L') {   // LISTEN
            errno = EAGAIN;
            return res;
        }
        errno = EIO;
        return res;
    }
    if (res >= 128 && res < 128 + 32) {
        __sock_fds |= (1 << (res - 128));
        __socket_nonblock(res, 0);
    }
    return res;
}
