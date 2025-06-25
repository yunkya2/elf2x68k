/*
 * _exit()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include "fds.h"

#ifdef LIBSOCKET
#include "libsocket/tcpipdrv.h"
uint32_t __sock_fds;
#endif

void _exit(int status)
{
  /* Close opened file */
  __fd_exit_clean ();

#ifdef LIBSOCKET
  /* Close opened socket */
  _ti_func func = _search_ti_entry();

  if (func) {
    for (int i = 31; i >= 0; i--) {
      if (__sock_fds & (1 << i)) {
        func(_TI_close_s, (long *)(128 + i));
        __sock_fds &= ~(1 << i);
      }
    }
  }
#endif

  _dos_exit2(status);
}
