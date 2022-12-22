/*
 * open()
 */

#include <fcntl.h>
#include <errno.h>
#undef errno
extern int errno;

#define ioctl_a1(num,a1)    __asm__ volatile ("movel %1,%%a1; movel %0,%%d0; trap #15" :: "i"(num), "a"(a1) : "%%d0", "%%a1")

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
                      : "=d"(res) : "d"(flags & 3), "a"(file) : "%%d0");
  }

  return res;
}
