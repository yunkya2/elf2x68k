/*
 * close()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

int close(int fd)
{
  int res;

  return _dos_close(fd);
}
