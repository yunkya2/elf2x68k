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
    res = _dos_read(fd, buf, count);
    if (res > 0) {
      char *p;
      char *q;
      char ch;

      p = buf;
      q = buf;
      while (res-- > 0) {
        ch = *p++;
        if (ch != '\r') {
          *q++ = ch;
        }
      }
      res = q - (char *)buf;
    }
  }

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  }

  return res;
}
