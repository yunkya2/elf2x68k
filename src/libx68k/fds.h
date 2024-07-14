#ifndef _FDS_H
#define _FDS_H

#include <sys/cdefs.h>
#include <x68k/dos.h>

#ifndef O_BINARY
#define O_BINARY        0x10000
#endif
#ifndef O_TEXT
#define O_TEXT          0x20000
#endif

typedef struct fdent fdent;

struct fdent {
  char *	filename;
  unsigned int	flags;
};

extern fdent __fd_list[];

#define __valid_fd(fd)		(__fd_list[fd].filename != NULL)
#define __fd_filename(fd)	(__fd_list[fd].filename)
#define __fd_flags(fd)		(__fd_list[fd].flags)

#include "../dirent.h"

typedef struct DIR DIR;

struct DIR {
  int active;     /* 0:free / 1:in-use / 2:in-use(no directory entry) */
  int count;
  char dirname[88 + 5];
  struct dirent dirent;
  struct dos_filbuf filbuf;
};

__BEGIN_DECLS

int	__fd_assign (int fd, const char *filename, unsigned int flags);
int	__fd_remove (int fd);
void	__fd_exit_clean (void);

__END_DECLS

#endif /* _FDS_H */
