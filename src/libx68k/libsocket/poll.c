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
                    if (__sock_listen_fds & (1 << (fds[i].fd - 128))) {
                        // ソケットがlisten()中だった場合、accept()が成功するかで接続完了を判断する
                        long arg[3];
                        int res;
                        struct sockaddr addr;
                        socklen_t addrlen = sizeof(addr);

                        arg[0] = fds[i].fd;
                        arg[1] = (long)&addr;
                        arg[2] = (long)&addrlen;

                        // TBD: ブロッキングのままでlisten()して接続完了をpoll()で待つ場合、
                        // ここでacceptがブロックしてしまうため一旦ノンブロッキングにすべきか?

                        res = __sock_func(_TI_accept, arg);
                        if (res >= 128 && res < 128 + 32) {
                            // acceptに成功して新しいソケットが得られた場合は接続完了
                            fds[i].revents |= POLLIN;
                            // 新たに生成されたソケットをオープン中のソケットのビットマスクに追加する
                            __sock_fds |= (1 << (res - 128));
                            // inted.xではノンブロッキングのaccept()で得られるソケットもノンブロッキングになるが、
                            // Linux等の仕様ではブロッキングになるためブロッキングモードを修正しておく
                            __socket_nonblock(res, 0);
                            // 得られたソケットはこの後のaccept()呼び出しで取得するため、その情報を保存しておく
                            __socket_push_accept(res, &addr, &addrlen);
                        } else {
                            char *state = __socket_sockstate(fds[i].fd);
                            if (!(state && *state == 'L')) { // not LISTEN
                                // ソケットの状態がLISTENでない場合はエラーとみなす
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
                        // ソケットがconnect()中だった場合、状態がESTABLISHEDになっているかどうかを確認する
                        char *state = __socket_sockstate(fds[i].fd);
                        if (state && *state == 'E') { // ESTABLISHED
                            // ソケットの状態がESTABLISHEDになっていれば接続完了
                            fds[i].revents |= POLLOUT;
                            // 接続が完了したのでソケットをconnect()中状態から外す
                            // (以降は通常のソケットとして扱う)
                            __sock_connect_fds &= ~(1 << (fds[i].fd - 128));
                        } else if (state == NULL) {
                            // ソケットの状態が取得できない場合はエラーとみなす
                            // (相手から接続を拒否された場合など)
                            // TBD: エラーの有無はgetsockopt(SO_SOCKERR)で渡すべき
                            fds[i].revents |= POLLERR;
                        }
                    } else {
                        // 通常のソケットの場合は送信可能かどうかをチェックする
                        // (送信バッファに空きがあるかどうかをチェックする手段がないため、
                        //  送信バッファが空かどうかで代用している)
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

//        _dos_sleep_pr(10);
        _dos_change_pr();
    }
}
