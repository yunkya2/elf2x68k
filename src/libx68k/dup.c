/*
 * dup()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#include "fds.h"

int __doserr2errno(int error);

int dup(int oldfd)
{
  int res = _dos_dup(oldfd);
  if (res < 0) {
    errno = __doserr2errno(-res);
    return -1;
  }

  if (__fd_assign(res, __fd_filename(oldfd), __fd_flags(oldfd)) < 0) {
    _dos_close(res);
    errno = EINVAL;
    return -1;
  }

  return res;
}
