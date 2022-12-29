/*
 * close()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;
#include "fds.h"

int close(int fd)
{
  int res;

  if (__fd_remove(fd) < 0)
    return -1;

  return _dos_close(fd);
}
