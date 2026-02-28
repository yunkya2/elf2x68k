/*
 * isatty()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>

int isatty(int fd)
{
  int res = _dos_ioctrlgt(fd);

  if (res < 0) {
    errno = EINVAL;
    return 0;
  } else if ((res & 0x800c) == 0x8000) {
    // character device, not NUL, not CLOCK
    return 1;
  } else {
    errno = ENOTTY;
    return 0;
  }
}
