/*
 * gettimeofday()
 */

#include "config.h"
#include <x68k/dos.h>
#include <sys/types.h>
#include <sys/time.h>
#include <time.h>
#include <errno.h>
#undef errno
extern int errno;

int gettimeofday(struct timeval *tv, void *tz)
{
  uint32_t curdate;
  uint32_t curtime;
  struct tm tm;
  int tm_mon;

  if (tv != NULL) {
    curdate = _dos_getdate();
    curtime = _dos_gettim2();

    tm.tm_sec  =  (curtime & 0x00003f);
    tm.tm_min  =  (curtime & 0x003f00) >> 8;
    tm.tm_hour =  (curtime & 0x1f0000) >> 16;
    tm.tm_mday =  (curdate & 0x001f);
    tm_mon     =  (curdate & 0x01e0) >> 5;
    tm.tm_mon  =  tm_mon > 0 ? tm_mon - 1 : tm_mon;
    tm.tm_year = ((curdate & 0xfe00) >> 9) + 80;
    tm.tm_isdst = 0;

    tv->tv_sec = mktime(&tm);
    tv->tv_usec = 0;
  }

  return 0;
}
