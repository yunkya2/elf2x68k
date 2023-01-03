/*
 * Stub version of fork.
 */

#include "config.h"
#include <_ansi.h>
#include <_syslist.h>
#include <errno.h>

int
_fork (void)
{
  errno = ENOSYS;
  return -1;
}
