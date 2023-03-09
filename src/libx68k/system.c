/*
 * _system()
 */

#include <x68k/dos.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int __doserr2errno(int error);

int _system(const char *command)
{
  char cmdname[256];
  char cmdarg[256];
  const char *shell = "command.x";
  char *s;
  int res;

  if ((s = getenv("SHELL")) != NULL) {
    shell = s;
  }

  if (strlen(shell) + 1 + strlen(command) > 255) {
    errno = E2BIG;
    return -1;
  }

  strcpy(cmdname, shell);
  strcat(cmdname, " ");
  strcat(cmdname, command);

  res = _dos_exec2(2, cmdname, cmdarg, 0);
  if (res < 0) {
    errno = __doserr2errno(-res);
    res = -1;
  } else {
    res = _dos_exec2(0, cmdname, cmdarg, 0);
    if (res < 0) {
      errno = __doserr2errno(-res);
      res = -1;
    }
  }

  return res;
}
