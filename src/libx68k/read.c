/*
 * read()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#include "fds.h"

int __doserr2errno(int error);

ssize_t read(int fd, void *buf, size_t count)
{
  int res;

  if (!isatty(fd) && !__valid_fd(fd)) {
    errno = EBADF;
    return -1;
  }

  if (count <= 0)
    return 0;

  if (!isatty(fd) && __fd_flags(fd) & O_BINARY) {
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
        if (ch != '\r') {
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
