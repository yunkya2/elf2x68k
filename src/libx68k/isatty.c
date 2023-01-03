/*
 * isatty()
 */

#include <unistd.h>
#include <errno.h>

int isatty(int fd)
{
  return fd < 5;
}
