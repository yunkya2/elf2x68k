/*
 * Stub version of getpid.
 */

#include "config.h"
#include <_ansi.h>
#include <_syslist.h>
#include <errno.h>

int
_getpid (void)
{
  errno = ENOSYS;
  return -1;
}
