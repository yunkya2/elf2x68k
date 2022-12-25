/*
 * unlink()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

int unlink (const char *pathname)
{
  return _dos_delete(pathname);
}
