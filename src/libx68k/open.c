/*
 * open()
 */

#include <x68k/dos.h>
#include <fcntl.h>
#include <errno.h>
#include "fds.h"

int __doserr2errno(int error);

int open(const char *file, int flags, ...)
{
  int fd;

  fd = _dos_open(file, flags & O_ACCMODE);

  if (fd < 0) {
    if (flags & O_CREAT) {
      fd = _dos_create(file, 0x20);   /* create normal file */
    }
    if (fd < 0) {
      errno = __doserr2errno(-fd);
      return -1;
    }
  } else {
    if (flags & O_EXCL) {
      _dos_close(fd);
      errno = EEXIST;       /* file exist error */
      return -1;
    }
  }

  if (flags & O_TRUNC) {
    _dos_write(fd, 0, 0);   /* truncate exiting file */
  }
  if (flags & O_APPEND) {
    _dos_seek(fd, 0, 2);    /* seek to end of the file */
  }

  if (__fd_assign (fd, file, flags) < 0) {
    _dos_close(fd);
    errno = EINVAL;
    return -1;
  }

  return fd;
}
