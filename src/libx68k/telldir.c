/*
 * telldir()
 */

#include <x68k/dos.h>
#include <errno.h>
#include <string.h>
#include "fds.h"

int __doserr2errno(int error);

long telldir(DIR *dirp)
{
  if (dirp->active == 0) {
    errno = EBADF;
    return -1;
  }
  return dirp->count;
}
