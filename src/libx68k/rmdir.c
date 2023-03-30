/*
 * rmdir()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>

int __doserr2errno(int error);

int rmdir (const char *pathname)
{
  int res;

  res = _dos_rmdir(pathname);

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  }

  return res;
}
