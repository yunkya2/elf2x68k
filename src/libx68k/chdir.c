/*
 * chdir()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <ctype.h>
#include <errno.h>

int __doserr2errno(int error);

int chdir(const char *path)
{
  char drv = toupper(path[0]);
  int res;
  if (drv >= 'A' && drv <= 'Z' && path[1] == ':') {
    res = _dos_chgdrv(drv - 'A');
    if (res < 0) {
      errno = __doserr2errno(-res);
      return -1;
    }
  }
  res = _dos_chdir(path);
  if (res < 0) {
    errno = __doserr2errno(-res);
    return -1;
  }

  return res;
}
