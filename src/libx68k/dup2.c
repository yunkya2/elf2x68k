/*
 * dup2()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>
#include "fds.h"
#include "_at_exit.h"

int __doserr2errno(int error);

/* 最初にdup2()でfd 0～4の状態を変更する際の、各fdの割り当て先 */
static char dup0_status[5];

/* fd 0～4 の状態を起動前に戻す */
/* (ctty auxで実行したプロセスを元の状態に戻すため) */
static void dup2_at_exit(int type)
{
  for (int fd = 0; fd < 5; fd++) {
    _dos_dup0(dup0_status[fd], fd);
  }
}

/* プロセス終了時に実行するハンドラを登録する処理 */
/* (空の関数で上書きすることで、プロセス終了時にfd 0～4の状態を元に戻さない) */
__attribute__((weak)) void __dup2_register_at_exit(void)
{
  __at_exit(dup2_at_exit);
}

/* dup2()で最初にfd 0～4への上書きを行う際、その時点での状態を保存する */
static void dup2_init(void)
{
  static int at_exit_registered = 0;

  if (at_exit_registered) {
    return;
  }
  at_exit_registered = 1;
  __dup2_register_at_exit();

  for (int fd = 0; fd < 5; fd++) {
    dup0_status[fd] = _dos_dup0(fd, fd);
    _dos_dup0(dup0_status[fd], fd);
  }
}

int dup2(int oldfd, int newfd)
{
  // fd 0～4へのdup2()は_dos_dup0()で強制複写する
  // (プロセス終了時に元の状態に戻す)
  if (newfd >= 0 && newfd < 5) {
    dup2_init();
    int res = _dos_dup0(oldfd, newfd);
    if (res < 0) {
      errno = __doserr2errno(-res);
      return -1;
    }
    return newfd;
  }

  if (oldfd == newfd) {
    if (!__fd_isvalid(oldfd)) {
      errno = EBADF;
      return -1;
    }
    return newfd;
  }

  int res = _dos_dup2(oldfd, newfd);
  if (res < 0) {
    errno = __doserr2errno(-res);
    return -1;
  }

  __fd_remove(newfd);
  if (__fd_assign(newfd, __fd_filename(oldfd), __fd_flags(oldfd)) < 0) {
    _dos_close(newfd);
    errno = EINVAL;
    return -1;
  }

  return newfd;
}
