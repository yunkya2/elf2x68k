/*
 * sleep(), usleep()
 */

#include <x68k/iocs.h>
#include <x68k/dos.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

int __doserr2errno(int error);

int usleep(useconds_t usec)
{
  unsigned int msec = usec / 1000;

  long t0 = _dos_time_pr();

  if (t0 == -1) {
    /* Background task unavailable  */
    struct iocs_time ti0, ti1;

    ti0 = _iocs_ontime();
    unsigned int duration;
    do {
      ti1 = _iocs_ontime();
      duration = (ti1.sec - ti0.sec) + (ti1.day - ti0.day) * 24 * 60 * 60 * 100;
    } while (duration < msec / 10);
    return 0;
  }

  while (1) {
    long t1 = _dos_time_pr();
    int left = msec - (t1 - t0);
    if (left <= 0) {
      break;
    }
   _dos_sleep_pr(left);
  }
  return 0;
}

unsigned int sleep(unsigned int seconds)
{
  return usleep(seconds * 1000000);
}
