/*
 * open()
 */

#include <fcntl.h>
#include <errno.h>
#undef errno
extern int errno;

int open(const char *file, int flags, ...)
{
  int res;

  if (flags & O_CREAT) {
    __asm__ volatile ("movew %1, -(%%sp)\n"
                      "movel %2, -(%%sp)\n"
                      ".hword 0xff3c\n"
                      "addql #6,%%sp\n"
                      "movel %%d0, %0"
                      : "=d"(res) : "d"(0x20), "a"(file) : "%%d0");
  } else {
    __asm__ volatile ("movew %1, -(%%sp)\n"
                      "movel %2, -(%%sp)\n"
                      ".hword 0xff3d\n"
                      "addql #6,%%sp\n"
                      "movel %%d0, %0"
                      : "=d"(res) : "d"(flags), "a"(file) : "%%d0");
  }

  return res;
}
