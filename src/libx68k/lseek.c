/*
 * lseek()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>

int __doserr2errno(int error);

off_t lseek(int fd, off_t offset, int whence)
{
  int res;

  res = _dos_seek(fd, offset, whence);

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  }

  return (off_t)res;
}
