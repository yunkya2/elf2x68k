/*
 * write() (without Human68k)
 */

#include <x68k/iocs.h>
#include <unistd.h>
#include <errno.h>

ssize_t write(int fd, const void *buf, size_t count)
{
  int res = count;
  const char *p;
  char ch;

  if (fd != 1 && fd != 2) {
    errno = EBADF;
    return -1;
  }

  p = buf;
  while (count-- > 0) {
    ch = *p++;
    if (ch == '\n') {
      _iocs_b_putc('\r');
    }
    _iocs_b_putc(ch);
  }

  return res;
}
