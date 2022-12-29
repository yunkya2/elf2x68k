/*
 * open()
 */

#include <x68k/dos.h>
#include <fcntl.h>
#include <errno.h>
#undef errno
extern int errno;
#include "fds.h"

int open(const char *file, int flags, ...)
{
  int fd;

  if (flags & (O_CREAT | O_EXCL)) {
    fd = _dos_create(file, 0x20);   /* create normal file */
  } else {
    fd = _dos_open(file, flags & O_ACCMODE);
  }

  if ((fd >= 0) && (__fd_assign (fd, file, flags) < 0))
  {
    _dos_close(fd);
    return -1;
  }

  return fd;
}
