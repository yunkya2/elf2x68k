#include <x68k/dos.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <sys/syslimits.h>
#include <unistd.h>
#include "fds.h"

fdent __fd_list[OPEN_MAX] = {
  { NULL, 0 }, /* 0: stdin */
  { NULL, 0 }, /* 1: stdout */
  { NULL, 0 }, /* 2: stderr */
  { NULL, 0 }, /* 3: AUX */
  { NULL, 0 }, /* 4: PRN */
};

int
__fd_assign (int fd, const char *filename, unsigned int flags)
{
  fdent *fdptr;

  if ((fd < 0) || (fd >= OPEN_MAX))
    return -1;

  fdptr = &__fd_list[fd];

  /* Used fd */
  if (fdptr->filename != NULL)
    return -1;

  fdptr->filename = filename ? strdup (filename) : NULL;
  fdptr->flags = flags;

  return 0;
}

int
__fd_remove (int fd)
{
  fdent *fdptr;

  if ((fd < 0) || (fd >= OPEN_MAX))
    return -1;

  fdptr = &__fd_list[fd];

  /* Unused fd */
  if (fdptr->filename == NULL)
    return -1;

  free (fdptr->filename);
  fdptr->filename = NULL;
  fdptr->flags = 0;

  return 0;
}

void
__fd_exit_clean (void)
{
  int i;

  for (i = 5; i < OPEN_MAX; i++)
    __fd_remove (i);

  _dos_allclose();
}
