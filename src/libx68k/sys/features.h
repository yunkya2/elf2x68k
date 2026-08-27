#include_next <sys/features.h>

#ifndef _POSIX_THREADS
#define _POSIX_THREADS      1
#endif
#ifndef _POSIX_BARRIERS
#define _POSIX_BARRIERS     1
#endif
#ifndef _POSIX_SPIN_LOCKS
#define _POSIX_SPIN_LOCKS   1
#endif
#ifndef _POSIX_READER_WRITER_LOCKS
#define _POSIX_READER_WRITER_LOCKS  1
#endif
