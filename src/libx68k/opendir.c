/*
 * opendir()
 */

#include <x68k/dos.h>
#include <errno.h>
#include <string.h>
#include "fds.h"

#define MAX_OPENDIR   8

static DIR __dir_list[MAX_OPENDIR];

int __doserr2errno(int error);

DIR *opendir(const char *name)
{
  DIR *dirp;
  int i;

  for (i = 0; i < MAX_OPENDIR; i++) {
    if (!__dir_list[i].active) {    /* free entry found */
      dirp = &__dir_list[i];

      /* create pathname for DOS _FILES */
      if (strlen(name) == 0) {
        strcpy(dirp->dirname, "*.*");
      } else {
        strncpy(dirp->dirname, name, sizeof(dirp->dirname) - 5);
        dirp->dirname[sizeof(dirp->dirname) - 5 - 1] = '\0';
        strcat(dirp->dirname, "/*.*");
      }

      int res = _dos_files(&dirp->filbuf, dirp->dirname, 0x37);
      if (res >= 0) {
        dirp->active = 1;
      } else if (res == -18) {      /* no directory entry */
        dirp->active = 2;
      } else {
        errno = __doserr2errno(res);
        return NULL;
      }
      dirp->count = 0;
      return dirp;
    }
  }
}
