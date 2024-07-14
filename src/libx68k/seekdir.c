/*
 * seekdir(), rewinddir()
 */

#include <x68k/dos.h>
#include <errno.h>
#include <string.h>
#include "fds.h"

int __doserr2errno(int error);

void seekdir(DIR *dirp, long loc)
{
  if (dirp->active == 0) {
    errno = EBADF;
    return;
  }

  int res = _dos_files(&dirp->filbuf, dirp->dirname, 0x37);
  if (res >= 0) {
    dirp->active = 1;
  } else if (res == -18) {      /* no directory entry */
    dirp->active = 2;
  } else {
    errno = __doserr2errno(res);
    return;
  }
  dirp->count = 0;

  while (dirp->count < loc) {
    if (dirp->active == 2) {
      int res = _dos_nfiles(&dirp->filbuf);
      if (res < 0) {
        return;
      }
    }
    dirp->active = 2;
    dirp->count++;
  }
}

void rewinddir(DIR *dirp)
{
  seekdir(dirp, 0);
}
