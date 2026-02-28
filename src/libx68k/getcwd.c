/*
 * getcwd()
 */

#include <x68k/dos.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int __doserr2errno(int error);

char *getcwd(char *buf, size_t size)
{
  char tmpbuf[256];

  int drv = _dos_curdrv();
  tmpbuf[0] = 'A' + drv;
  tmpbuf[1] = ':';
  tmpbuf[2] = '/';
  _dos_curdir(0, tmpbuf + 3);

  unsigned char *p;
  for (p = tmpbuf; *p; p++) {
    if (*p == '\\') {
      *p = '/';
    } else if ((*p >= 0x80 && *p <= 0x9f) || (*p >= 0xe0)) {
      p++;
    }
  }

  int len = p - (unsigned char *)tmpbuf + 1;
  if (buf == NULL) {
    size = size ? size : len;
    buf = malloc(len);
    if (buf == NULL) {
      errno = ENOMEM;
      return NULL;
    }
  }

  if (size < (size_t)len) {
    errno = ERANGE;
    return NULL;
  }

  memcpy(buf, tmpbuf, len);
  return buf;
}
