/*
 * lseek()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

off_t lseek(int fd, off_t offset, int whence)
{
  return _dos_seek(fd, offset, whence);
}
