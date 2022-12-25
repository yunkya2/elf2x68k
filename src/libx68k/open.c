/*
 * open()
 */

#include <x68k/dos.h>
#include <fcntl.h>
#include <errno.h>
#undef errno
extern int errno;

int open(const char *file, int flags, ...)
{
  int fd;

  if (flags & O_CREAT) {
    fd = _dos_create(file, 0x20);
  } else {
    fd = _dos_open(file, flags & 3);
  }

  return fd;
}
