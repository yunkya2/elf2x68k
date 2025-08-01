/*
 * close()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#include "fds.h"

#ifdef LIBSOCKET
#include "libsocket/tcpipdrv.h"
extern uint32_t __sock_fds;
#endif

int __doserr2errno(int error);

int close(int fd)
{
  int res;

#ifdef LIBSOCKET
  if (fd >= 128) {
    if (!__sock_func) {
      errno = ENOSYS;
      return -1;
    }

    int res;

    res = __sock_func(_TI_close_s, (long *)fd);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    if (fd >= 128 && fd < 128 + 32) {
        __sock_fds &= ~(1 << (fd - 128));
    }
    return res;
  }
#endif

  res = _dos_close(fd);

  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  } else {
    __fd_remove(fd);
  }

  return res;
}
