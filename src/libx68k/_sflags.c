/*
 * __sflags() wrapper to support text/binary mode for fopen()
 */

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include "fds.h"

int __real___sflags(void *ptr, char *mode, int *optr);

int __wrap___sflags(void *ptr, char *mode, int *optr)
{
  int c;
  int m = 0;
  int flags;
  char *mp = mode;

  while (c = *mp++) {
    switch (c) {
      case 'b':
        m |= O_BINARY; 
        break;
      case 't':
        m |= O_TEXT;
        break;
    }
  }

  flags = __real___sflags(ptr, mode, optr);
  *optr |= m;
  return flags;
}
