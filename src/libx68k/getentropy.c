/*
 * Stub version of getentropy.
 */

#include "config.h"
#include <_ansi.h>
#include <_syslist.h>
#include <unistd.h>
#include <errno.h>

int
getentropy (void *buffer, size_t length)
{
  errno = ENOSYS;
  return -1;
}
