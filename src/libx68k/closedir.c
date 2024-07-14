/*
 * closedir()
 */

#include <x68k/dos.h>
#include <errno.h>
#include <string.h>
#include "fds.h"

int __doserr2errno(int error);

int closedir(DIR *dirp)
{
  if (dirp->active == 0) {
    errno = EBADF;
    return -1;
  }
  dirp->active = 0;
  return 0;
}
