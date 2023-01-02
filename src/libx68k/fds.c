#include <x68k/dos.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <sys/syslimits.h>
#include <unistd.h>
#include "fds.h"

fdent __fd_list[OPEN_MAX];

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

  memset (fdptr, 0, sizeof (fdent));

  fdptr->filename = strdup (filename);
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
  memset (fdptr, 0, sizeof (fdent));

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
