/*
 *  connect()
 */

#include "socket_internal.h"

int __socket_connect_confirm(int sockfd)
{
    if (sockfd >= 128 && sockfd < 128 + 32 && (__sock_connect_fds & (1 << (sockfd - 128)))) {
        char *state = __socket_sockstate(sockfd);
        if (state && *state == 'E') { // ESTABLISHED
            // 接続が完了したのでソケットをconnect()中状態から外す
            __sock_connect_fds &= ~(1 << (sockfd - 128));
            return 0;   // 接続完了
        } else if (state == NULL) {
            __sock_connect_fds &= ~(1 << (sockfd - 128));
            return EIO; // ソケットの状態が取得できない場合はエラー
        }
        return EINPROGRESS; // 接続中
    }
    return -1; // connect()中でないソケットはエラー
}

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

    __sock_errno = 0;
    res = __sock_func(_TI_connect, arg);
    if (res < 0) {
        char *state = __socket_sockstate(sockfd);
        if (state && (*state == 'S' || *state == 'E')) {   // SYN SENT or ESTABLISHED
            __sock_connect_fds |= (1 << (sockfd - 128));
            __sock_errno = errno = EINPROGRESS;
            return res;
        }
        __sock_errno = errno = EIO;
        return res;
    }
    return res;
}
