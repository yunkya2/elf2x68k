/*
 * write()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#include "fds.h"

#ifdef LIBSOCKET
#include "socket_internal.h"
#endif

#define TEXTBUFSIZE   256

int __doserr2errno(int error);

#ifdef LIBSOCKET
int __socket_handle_send_result(int sockfd)
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
    if (state == NULL || *state != 'E') { // ESTABLISHED以外
      return EIO;
    } else {
      return EAGAIN;
    }
  }
}
#endif

ssize_t write(int fd, const void *buf, size_t count)
{
  int res;
  size_t c;

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
    res = __sock_func(_TI_write_s, arg);
    if (res < 0) {
      int stat = __socket_handle_send_result(fd);
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
    res = _dos_write(fd, buf, count);
  } else {
    char textbuf[TEXTBUFSIZE + 1];  /* extra space is needed for '\r' */
    char *p;
    char ch;

    c = count;
    while (c > 0) {
      p = textbuf;
      while ((c > 0) && (p - textbuf < TEXTBUFSIZE)) {
        ch = *(char *)buf++;
        c--;
        if (ch == '\n') {
          *p++ = '\r';
        }
        *p++ = ch;
      }
      res = _dos_write(fd, textbuf, p - textbuf);
      if (res < 0)
        break;
    }
    if (res > 0)
      res = count;
  }

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  }

  return res;
}
