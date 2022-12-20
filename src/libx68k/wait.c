/*
 * wait()
 */

#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#undef errno
extern int errno;

pid_t wait(int *wstatus)
{
  __asm__ volatile (".hword 0xff4d\n"
                    "movel %%d0, %0"
                    : "=d"(*wstatus) : : "%%d0");

  return 0;
}
