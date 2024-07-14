/*
 * readdir()
 */

#include <x68k/dos.h>
#include <errno.h>
#include <string.h>
#include "fds.h"

int __doserr2errno(int error);

struct dirent *readdir(DIR *dirp)
{
  if (dirp->active == 2) {
    int res = _dos_nfiles(&dirp->filbuf);
    if (res < 0) {
      return NULL;
    }
  }

  dirp->dirent.d_ino = 0;
  dirp->dirent.d_off = dirp->count;
  dirp->dirent.d_reclen = sizeof(struct dirent);
  dirp->dirent.d_type = (dirp->filbuf.atr & 0x10) ? DT_DIR : DT_REG;
  strncpy(dirp->dirent.d_name, dirp->filbuf.name, sizeof(dirp->filbuf.name));
  dirp->active = 2;
  dirp->count++;
  return &dirp->dirent;
}
