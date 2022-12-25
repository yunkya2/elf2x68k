/*
 * read()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

ssize_t read(int fd, void *buf, size_t count)
{
  return _dos_read(fd, buf, count);
}
