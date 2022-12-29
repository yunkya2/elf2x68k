/*
 * write()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;
#include "fds.h"

#define TEXTBUFSIZE   256

ssize_t write(int fd, const void *buf, size_t count)
{
  int res;

  if (!isatty(fd) && !__valid_fd(fd)) {
    errno = EBADF;
    return -1;
  }

  if (count <= 0)
    return 0;

  if (!isatty(fd) && __fd_flags(fd) & O_BINARY) {
    res = _dos_write(fd, buf, count);
  } else {
    char textbuf[TEXTBUFSIZE];
    char *p;
    char ch;

    res = count;
    while (count > 0) {
      p = textbuf;
      while ((count > 0) && (p - textbuf < sizeof(textbuf))) {
        ch = *(char *)buf++;
        count--;
        if (ch == '\n') {
          *p++ = '\r';
        }
        *p++ = ch;
      }
      _dos_write(fd, textbuf, p - textbuf);
    }
  }

  return res;
}
