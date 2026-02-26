/*
 *  poll()
 */

#include "socket_internal.h"

#include <stdlib.h>
#include <poll.h>
#include <x68k/dos.h>

static int socklen(int fd, int mode)
{
    long arg[2];

    arg[0] = fd;
    arg[1] = mode;

    return __sock_func(_TI_socklen, arg);
}

int poll(struct pollfd *fds, nfds_t nfds, int timeout)
{
    if (!__sock_func) {
        errno = ENOSYS;
        return -1;
    }

    if (fds == NULL || nfds == 0) {
        errno = EINVAL;
        return -1;
    }

    long t0 = _dos_time_pr();

    while (1) {
        int nevents = 0;
        for (nfds_t i = 0; i < nfds; i++) {
            fds[i].revents = 0;
            if (fds[i].fd < 128 || fds[i].fd >= 128 + 32) {
                fds[i].revents |= POLLERR;
            } else {
                if (fds[i].events & POLLIN) {
                    // POLLINでは、listen()中のソケットの接続完了とそれ以外のソケットの受信可否をチェックできる
                    if (__sock_listen_fds & (1 << (fds[i].fd - 128)) && !__socket_accept_issaved()) {
                        // ソケットがlisten()中だった場合
                        struct sockaddr addr;
                        socklen_t addrlen = sizeof(addr);

                        // accept()が成功するかどうかをチェックするため、一旦ノンブロッキングにしてaccept()を呼び出す
                        int blocking = __socket_nonblock(fds[i].fd, 1);
                        int res = __socket_accept_internal(fds[i].fd, &addr, &addrlen);
                        __socket_nonblock(fds[i].fd, blocking);

                        if (res >= 0) {
                            // acceptに成功して新しいソケットが得られた場合は接続完了
                            fds[i].revents |= POLLIN;
                            // 得られたソケットはこの後のaccept()呼び出しで取得するため、その情報を保存しておく
                            __socket_accept_save(fds[i].fd, res, &addr, &addrlen);
                        } else {
                            if (errno != EAGAIN) {
                                // accept()がEAGAIN以外のエラーで失敗した場合はエラーとみなす
                                fds[i].revents |= POLLERR;
                            }
                        }
                    } else {
                        // 通常のソケットの場合は受信可能かどうかをチェックする
                        // (受信バッファが空でないか)
                        int r = socklen(fds[i].fd, 0);
                        if (r > 0) {
                            fds[i].revents |= POLLIN;
                        } else if (r < 0) {
                            fds[i].revents |= POLLERR;
                        }
                    }
                }
                if (fds[i].events & POLLOUT) {
                    // POLLOUTでは、connect()中のソケットの接続完了とそれ以外のソケットの送信可否をチェックできる
                    if (__sock_connect_fds & (1 << (fds[i].fd - 128))) {
                        // ソケットがconnect()中だった場合、接続完了したかどうかをチェックする
                        // (結果は後で呼び出すgetsockopt(SO_ERROR)で返す)
                        __sock_errno = __socket_connect_confirm(fds[i].fd);
                        if (__sock_errno != EINPROGRESS) { // 接続完了 or エラー
                            fds[i].revents |= POLLOUT;
                        }
                    } else {
                        // 通常のソケットの場合は送信可能かどうかをチェックする
                        // (送信バッファが空かどうか)
                        int r = socklen(fds[i].fd, 1);
                        if (r == 0) {
                            fds[i].revents |= POLLOUT;
                        } else if (r < 0) {
                            fds[i].revents |= POLLERR;
                        }
                    }
                }
            }
            if (fds[i].revents != 0) {
                nevents++;
            }
        }
        if (nevents > 0) {
            return nevents;
        }

        long elapsed = _dos_time_pr() - t0;
        if (timeout >= 0 && elapsed >= timeout) {
            return 0;
        }

        _dos_change_pr();
    }
}
