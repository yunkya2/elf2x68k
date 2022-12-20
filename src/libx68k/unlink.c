/*
 * unlink()
 */

#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

int unlink (const char *pathname)
{
  int res;

  __asm__ volatile ("movel %1, -(%%sp)\n"
                    ".hword 0xff41\n"
                    "addql #4,%%sp\n"
                    "movel %%d0, %0"
                    : "=d"(res) : "a"(pathname) : "%%d0");

  return res;
}
