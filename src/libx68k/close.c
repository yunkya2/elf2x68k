/*
 * close()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;
#include "fds.h"

int __doserr2errno(int error);

int close(int fd)
{
  int res;

  res = _dos_close(fd);

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  } else {
    __fd_remove(fd);
  }

  return res;
}
