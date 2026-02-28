/*
 *  accept()
 */

#include "socket_internal.h"

static int accept_fd = -1;
static int accept_newfd;
static struct sockaddr accept_addr;

int __socket_accept_issaved(void)
{
    return accept_fd >= 0;
}

int __socket_accept_save(int sockfd, int newfd, struct sockaddr *addr, socklen_t *addrlen)
{
    if (accept_fd >= 0) {
        return -1;
    } else {
        accept_fd = sockfd;
        accept_newfd = newfd;
        accept_addr = *addr;
        return 0;
    }
}

static int __socket_accept_restore(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
    if (accept_fd < 0 || accept_fd != sockfd) {
        return -1;
    } else {
        accept_fd = -1;
        if (addr && addrlen) {
            socklen_t copy_len = (*addrlen < sizeof(accept_addr)) ? *addrlen : sizeof(accept_addr);
            memcpy(addr, &accept_addr, copy_len);
            *addrlen = copy_len;
        }
        return accept_newfd;
    }
}

int __socket_accept_internal(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
    long arg[3];
    int res;

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
        // 新たに生成されたソケットをオープン中のソケットのビットマスクに追加する
        __sock_fds |= (1 << (res - 128));
        // inted.xではノンブロッキングのaccept()で得られるソケットもノンブロッキングになるが、
        // Linux等の仕様ではブロッキングになるためブロッキングモードを修正する
        __socket_nonblock(res, 0);
    }
    return res;
}


int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    int res = __socket_accept_restore(sockfd, addr, addrlen);
    if (res >= 0) {
        return res;
    }

    return __socket_accept_internal(sockfd, addr, addrlen);
}
