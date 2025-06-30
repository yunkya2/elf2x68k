/*
 * _exit()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include "fds.h"

void _exit(int status)
{
  /* Close opened file */
  __fd_exit_clean ();

  _dos_exit2(status);
}
