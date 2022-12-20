/*
 * _exit()
 */

#include <unistd.h>

void _exit(int status)
{
    __asm__ volatile ("movew %0, -(%%sp)\n"
                      ".hword 0xff4c\n"
                      : : "d"(status) : "%%d0");

  while (1)
    ;
}
