/*
 * Stub version of link.
 */

#include "config.h"
#include <_ansi.h>
#include <_syslist.h>
#include <errno.h>

int
_link (char *existing,
        char *new)
{
  errno = ENOSYS;
  return -1;
}
