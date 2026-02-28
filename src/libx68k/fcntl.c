/*
 * Stub version of fcntl.
 */

#include "config.h"
#include <_ansi.h>
#include <_syslist.h>
#include <stdarg.h>
#include <fcntl.h>
#include <errno.h>

#ifdef LIBSOCKET
#include "socket_internal.h"
#endif

int
_fcntl (int fd, int cmd, ...)
{
#ifdef LIBSOCKET
  if (fd >= 128) {
    switch (cmd) {
    case F_GETFL:
      {
        return (__socket_nonblock(fd, -1) > 0) ? O_NONBLOCK : 0;
      }
    case F_SETFL:
      {
        va_list ap;
        int flags;

        va_start(ap, cmd);
        flags = va_arg(ap, int);
        va_end(ap);

        if (__socket_nonblock(fd, (flags & O_NONBLOCK) ? 1 : 0) < 0) {
          errno = EIO;
          return -1;
        }
        return 0;
      }
    default:
      break;
    }
  }
#endif

  errno = ENOSYS;
  return -1;
}
