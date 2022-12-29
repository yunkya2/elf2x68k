#ifndef _FDS_H
#define _FDS_H

#include <sys/cdefs.h>

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

__BEGIN_DECLS

int	__fd_assign (int fd, const char *filename, unsigned int flags);
int	__fd_remove (int fd);
void	__fd_exit_clean (void);

__END_DECLS

#endif /* _FDS_H */
