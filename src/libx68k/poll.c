/*
 *  poll()
 */

#include <stdlib.h>
#include "libsocket/include/poll.h"
#include <x68k/dos.h>
#include <x68k/iocs.h>
#include <errno.h>

#ifdef LIBSOCKET
#include "socket_internal.h"

static int socklen(int fd, int mode)
{
    long arg[2];

    arg[0] = fd;
    arg[1] = mode;

    return __sock_func(_TI_socklen, arg);
}
#endif

int poll(struct pollfd *fds, nfds_t nfds, int timeout)
{
    if (fds == NULL || nfds == 0) {
        errno = EINVAL;
        return -1;
    }

#ifdef LIBSOCKET
    long t0 = _dos_time_pr();
#else
    struct iocs_time t0 = _iocs_ontime();
#endif

    while (1) {
        int nevents = 0;
        for (nfds_t i = 0; i < nfds; i++) {
            fds[i].revents = 0;
            if (fds[i].fd < 128) {
                // ファイルやデバイスのfdに対して入出力可能かどうかをチェックする

                if (fds[i].events & POLLIN) {
                    // IOCTRLの入力ステータスでは入力有無が判断できないためデバイスごとに個別対応する
                    // デバイスを判断するため装置情報を取得する

                    int res = _dos_ioctrlgt(fds[i].fd);
                    if (res >= 0) {
                        if ((res & 0x8001) == 0x8001) {
                            // 標準入力(CON)デバイスはIOCTRLの入力ステータスで入力有無が判断できないので
                            // DOS _INPOUT(-2)による入力先読みで入力があるかどうかをチェックする
                            fds[i].revents |= _dos_inpout(-2) ? POLLIN : 0;
                        } else {
                            // それ以外の場合はIOCTRLの入力ステータスをチェックする
                            // 正しい結果が得られるかはドライバの実装による
                            // ex. Human68kの内蔵AUXドライバは入力ステータスが常に0になるが、
                            //     RSDRV.SYSのAUXドライバは正しい入力ステータスを返す

                            int res = _dos_ioctrlis(fds[i].fd);
                            if (res == 0 || res == -1) {
                                fds[i].revents |= res ? POLLIN : 0;
                            } else if (res < 0) {
                                fds[i].revents |= POLLERR;
                            }
                        }
                    } else {
                        fds[i].revents |= POLLERR;
                    }
                }
                if (fds[i].events & POLLOUT) {
                    // IOCTRLで出力ステータスをチェックする
                    // AUX, PRNはこのチェックで出力可能かどうかを判断できる
                    // その他のデバイスはドライバの実装による

                    int res = _dos_ioctrlos(fds[i].fd);
                    if (res == 0 || res == -1) {
                        fds[i].revents |= res ? POLLOUT : 0;
                    } else if (res < 0) {
                        fds[i].revents |= POLLERR;
                    }
                }
#ifdef LIBSOCKET
            } else if (fds[i].fd < 128 + 32 && __sock_func) {
                // ソケットのfdに対して入出力可能かどうかをチェックする

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
                        if (__sock_errno == 0) { // 接続完了
                            fds[i].revents |= POLLOUT;
                        } else if (__sock_errno != EINPROGRESS) { // エラー
                            fds[i].revents |= POLLERR;
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
#endif
            } else {
                if (fds[i].events) {
                    fds[i].revents |= POLLERR;
                }
            }
            if (fds[i].revents != 0) {
                nevents++;
            }
        }
        if (nevents > 0) {
            return nevents;
        }

#ifdef LIBSOCKET
        long elapsed = _dos_time_pr() - t0;
        if (timeout >= 0 && elapsed >= timeout) {
            return 0;
        }
#else
        struct iocs_time t1 = _iocs_ontime();
        long elapsed = (t1.sec - t0.sec) + (t1.day - t0.day) * 24 * 60 * 60 * 100;
        if (timeout >= 0 && (elapsed * 10) >= timeout) {
            return 0;
        }
#endif

        _dos_change_pr();
    }
}
