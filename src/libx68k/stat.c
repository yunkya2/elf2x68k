/*
 * stat()
 */

#include <x68k/dos.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <errno.h>

int __doserr2errno(int error);

int stat (const char *file, struct stat *st)
{
  struct dos_filbuf fb;
  int ret;

  ret = _dos_files(&fb, file, 0x37);
  if (ret < 0) {
    errno = __doserr2errno(-ret);
    return -1;
  }

  memset(st, 0, sizeof(struct stat));

  if (fb.atr & 0x10) {
    st->st_mode = S_IFDIR | 0777;   /* directory */
  } else if (fb.atr & 0x20) {
    if (fb.atr & 0x01) {
      st->st_mode = S_IFREG | 0444; /* read only file */
    } else {
      st->st_mode = S_IFREG | 0666; /* file */
    }
    if (fb.ext[1] == ' ' && fb.ext[2] == ' ') {
      char ch = fb.ext[0] | 0x20;
      if (ch == 'x' || ch == 'z') {
        st->st_mode |= 0111;        /* executable */
      }
    }
  } else {
    st->st_mode = 0;
  }

  st->st_dev = 0;
  st->st_ino = 0;
  st->st_nlink = 1;
  st->st_uid = 0;
  st->st_gid = 0;
  st->st_rdev = 0;
  st->st_size = fb.filelen;
  st->st_blksize = 512;
  st->st_blocks = (st->st_size + st->st_blksize - 1) / st->st_blksize;

  struct tm tm = {
    (fb.time & 0x1f) << 1,
    (fb.time >> 5) & 0x3f,
    (fb.time >> 11) & 0x1f,
    (fb.date & 0x1f),
    ((fb.date >> 5) & 0xf) - 1,
    ((fb.date >> 9) & 0x7f) + 80,
    0, 0, 0
  };
  time_t tt = mktime(&tm);
  st->st_atime = tt;
  st->st_mtime = tt;
  st->st_ctime = tt;

  return 0;
}
