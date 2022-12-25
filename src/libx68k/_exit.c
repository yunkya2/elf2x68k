/*
 * _exit()
 */

#include <x68k/dos.h>
#include <unistd.h>

void _exit(int status)
{
  _dos_exit2(status);

  while (1)
    ;
}
