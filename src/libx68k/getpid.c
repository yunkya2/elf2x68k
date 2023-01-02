/*
 * Stub version of getpid.
 */

#include "config.h"
#include <_ansi.h>
#include <_syslist.h>
#include <errno.h>
#undef errno
extern int errno;

int
_getpid (void)
{
  errno = ENOSYS;
  return -1;
}
