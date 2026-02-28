/*
 * read()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#include "fds.h"

#ifdef LIBSOCKET
#include "socket_internal.h"
#endif

int __doserr2errno(int error);

#ifdef LIBSOCKET
int __socket_handle_recv_result(int sockfd)
{
  if (__socket_nonblock(sockfd, -1) == 0) {
    // ブロッキングモードだった場合

    // ノンブロッキングモードのaccept()から得られたソケットはまだ3way handshakeが
    // 完了していない場合があり、そうしたソケットをブロッキングで利用するとエラー終了してしまう
    // (inetd.xの挙動)
    // これを回避するため、ブロッキングモードでもソケットの状態がSYN RECEIVEDだったら
    // ESTABLISHEDになるまで待つ

    while (1) {
      char *state = __socket_sockstate(sockfd);
      if (state == NULL) {
        return EIO;
      } else if (*state != 'S') {
        return 0; // ブロッキングモードでSYN RECEIVED以外の状態になったら待ち終了
      }
      _dos_change_pr();
    }
  } else {
    // ノンブロッキングモードだった場合
    char *state = __socket_sockstate(sockfd);
    if (state == NULL) {
      return EIO;
    } else {
      return EAGAIN;
    }
  }
}
#endif

ssize_t read(int fd, void *buf, size_t count)
{
  int res;

#ifdef LIBSOCKET
  if (fd >= 128) {
    if (!__sock_func) {
      errno = ENOSYS;
      return -1;
    }

    long arg[3];
    ssize_t res;

    arg[0] = fd;
    arg[1] = (long)buf;
    arg[2] = count;

retry:
    res = __sock_func(_TI_read_s, arg);
    if (res < 0) {
      int stat = __socket_handle_recv_result(fd);
      if (stat == 0) {
        goto retry;
      }
      errno = stat;
      return res;
    }
    return res;
  }
#endif

  if (!__fd_isvalid(fd)) {
    errno = EBADF;
    return -1;
  }

  if (count <= 0)
    return 0;

  if (__fd_flags(fd) & O_BINARY) {
    res = _dos_read(fd, buf, count);
  } else {
    char *p = buf;
    int r;
    res = 0;
    while (count > 0) {
      r = _dos_read(fd, p, count);
      if (r == 0) {
        break;
      } else if (r < 0) {
        res = r;
        break;
      }
      char *q = p;
      char ch;

      while (r-- > 0) {
        ch = *q++;
        if (ch != '\r' && ch != '\x1a') {
          *p++ = ch;
          res++;
          count--;
        }
      }
      if ( isatty(fd) ) break;
    }
  }

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  }

  return res;
}
