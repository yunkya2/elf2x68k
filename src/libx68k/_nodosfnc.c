/*
 * Stub functions without Human68k
 */

#include <errno.h>

int __nodos_nosys(void)
{
  errno = ENOSYS;
  return -1;
}

int chown(void) __attribute__ ((alias("__nodos_nosys")));
int close(void) __attribute__ ((alias("__nodos_nosys")));
int fork(void) __attribute__ ((alias("__nodos_nosys")));
int fstat(void) __attribute__ ((alias("__nodos_nosys")));
int getpid(void) __attribute__ ((alias("__nodos_nosys")));
int gettimeofday(void) __attribute__ ((alias("__nodos_nosys")));
int isatty(void) __attribute__ ((alias("__nodos_nosys")));
int kill(void) __attribute__ ((alias("__nodos_nosys")));
int link(void) __attribute__ ((alias("__nodos_nosys")));
int lseek(void) __attribute__ ((alias("__nodos_nosys")));
int open(void) __attribute__ ((alias("__nodos_nosys")));
int read(void) __attribute__ ((alias("__nodos_nosys")));
int readlink(void) __attribute__ ((alias("__nodos_nosys")));
int stat(void) __attribute__ ((alias("__nodos_nosys")));
int symlink(void) __attribute__ ((alias("__nodos_nosys")));
int times(void) __attribute__ ((alias("__nodos_nosys")));
int unlink(void) __attribute__ ((alias("__nodos_nosys")));
int wait(void) __attribute__ ((alias("__nodos_nosys")));
