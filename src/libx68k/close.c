/*
 * close()
 */

#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

int close(int fd)
{
  int res;

  __asm__ volatile ("movew %1, -(%%sp)\n"
                    ".hword 0xff3e\n"
                    "addql #2,%%sp\n"
                    "movel %%d0, %0"
                    : "=d"(res) : "d"(fd) : "%%d0");

  return res;
}
