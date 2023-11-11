/*
 * fstat()
 */

#include "config.h"
#include <x68k/dos.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <errno.h>

int fstat(int fd, struct stat *st)
{
  uint32_t filedate;
  uint32_t filepos;
  struct tm tm;
  int tm_mon;

  memset(st, 0, sizeof(struct stat));

  if (fd < 5) {
    st->st_mode = S_IFCHR;
    st->st_nlink = 1;
    return 0;
  }

  filedate = _dos_filedate(fd, 0);
  if ((filedate & 0xffff0000) == 0xffff0000) {
    errno = EBADF;
    return -1;
  }
  tm.tm_sec  =  (filedate & 0x0000001f) << 1;
  tm.tm_min  =  (filedate & 0x000007e0) >> 5;
  tm.tm_hour =  (filedate & 0x0000f800) >> 11;
  tm.tm_mday =  (filedate & 0x001f0000) >> 16;
  tm_mon     =  (filedate & 0x01e00000) >> 21;
  tm.tm_mon  =  tm_mon > 0 ? tm_mon - 1 : tm_mon;
  tm.tm_year = ((filedate & 0xfe000000) >> 25) + 80;
  tm.tm_isdst = 0;
  st->st_atime = st->st_ctime = st->st_mtime = mktime(&tm);

  filepos = _dos_seek(fd, 0, 1);
  st->st_size = _dos_seek(fd, 0, 2);
  _dos_seek(fd, filepos, 0);
  st->st_blksize = 512;
  st->st_blocks = (st->st_size + st->st_blksize - 1) / st->st_blksize;

  st->st_mode = S_IFREG | 0777;
  st->st_nlink = 1;
  return 0;
}
