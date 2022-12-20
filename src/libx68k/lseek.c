/*
 * lseek()
 */

#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

off_t lseek(int fd, off_t offset, int whence)
{
  int res;

  __asm__ volatile ("movew %1, -(%%sp)\n"
                    "movel %2, -(%%sp)\n"
                    "movew %3, -(%%sp)\n"
                    ".hword 0xff42\n"
                    "addql #8,%%sp\n"
                    "movel %%d0, %0"
                    : "=d"(res) : "d"(whence), "a"(offset), "d"(fd) : "%%d0");

  return res;
}
