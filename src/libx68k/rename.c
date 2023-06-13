/*
 * rename()
 */

#include <x68k/dos.h>
#include <stdio.h>
#include <errno.h>

int __doserr2errno(int error);

int rename (const char *old_path, const char *new_path)
{
  int res;

  res = _dos_rename(old_path, new_path);

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  }

  return res;
}
