/*
 * wait()
 */

#include <x68k/dos.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>

pid_t wait(int *wstatus)
{
  *wstatus = _dos_wait();

  return 0;
}
