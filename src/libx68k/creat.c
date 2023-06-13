/*
 * creat()
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int creat(const char *file, mode_t mode)
{
  return open(file, O_CREAT|O_WRONLY|O_TRUNC, mode);
}
