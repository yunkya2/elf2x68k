/*
 * write()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

ssize_t write(int fd, const void *buf, size_t count)
{
  int res;

  if (isatty(fd)) {
    char ch;

    res = 0;
    while (count-- > 0) {
      ch = *(char *)buf++;
      if (ch == '\n') {
        _dos_fputc('\r', fd);
      }
        _dos_fputc(ch, fd);
    }
    res = count;
  } else {
    res = _dos_write(fd, buf, count);
  }

  return res;
}
