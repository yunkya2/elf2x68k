/*
 * Stub version of fcntl.
 */

#include "config.h"
#include <_ansi.h>
#include <_syslist.h>
#include <errno.h>

int
_fcntl (int fd, int cmd, ...)
{
  errno = ENOSYS;
  return -1;
}
