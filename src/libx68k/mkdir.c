/*
 * mkdir()
 */

#include <x68k/dos.h>
#include <sys/stat.h>
#include <errno.h>

int __doserr2errno(int error);

int mkdir (const char *pathname, mode_t mode)
{
  int res;

  res = _dos_mkdir(pathname);

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  }

  return res;
}
