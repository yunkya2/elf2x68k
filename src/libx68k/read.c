/*
 * read()
 */

#include <unistd.h>
#include <errno.h>
#undef errno
extern int errno;

ssize_t read(int fd, void *buf, size_t count)
{
  int res;

  __asm__ volatile ("movel %1, -(%%sp)\n"
                    "movel %2, -(%%sp)\n"
                    "movew %3, -(%%sp)\n"
                    ".hword 0xff3f\n"
                    "lea 10(%%sp),%%sp\n"
                    "movel %%d0, %0"
                    : "=d"(res) : "d"(count), "a"(buf), "d"(fd) : "%%d0");

  return res;
}
