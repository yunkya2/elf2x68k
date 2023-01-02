/*
 * open()
 */

#include <x68k/dos.h>
#include <fcntl.h>
#include <errno.h>
#undef errno
extern int errno;
#include "fds.h"

int __doserr2errno(int error);

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
    errno = EINVAL;
    return -1;
  }

  if (fd < 0) {
    errno = __doserr2errno(-fd);
    fd = -1;
  }

  return fd;
}
