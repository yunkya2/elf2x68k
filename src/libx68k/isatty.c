/*
 * isatty()
 */

#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

int isatty(int fd)
{
  return fd < 5;
}
