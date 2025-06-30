/*
 * write()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#include "fds.h"

#ifdef LIBSOCKET
#include "libsocket/tcpipdrv.h"
#endif

#define TEXTBUFSIZE   256

int __doserr2errno(int error);

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

    res = __sock_func(_TI_write_s, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    return res;
  }
#endif

  if (!isatty(fd) && !__valid_fd(fd)) {
    errno = EBADF;
    return -1;
  }

  if (count <= 0)
    return 0;

  if (!isatty(fd) && __fd_flags(fd) & O_BINARY) {
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
