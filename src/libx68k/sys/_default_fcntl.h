#include_next <sys/_default_fcntl.h>

#ifndef O_BINARY
#define O_BINARY	0x10000
#endif
#ifndef O_TEXT
#define O_TEXT		0x20000
#endif
