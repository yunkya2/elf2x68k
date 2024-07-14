#ifndef _SYS_DIRENT_H_
#define	_SYS_DIRENT_H_

#include <sys/cdefs.h>
#include <sys/types.h>

__BEGIN_DECLS

#define MAXNAMLEN       255

struct dirent {
  ino_t  d_ino;
  off_t  d_off;
  unsigned short d_reclen;
  unsigned char  d_type;
  char   d_name[MAXNAMLEN + 1];
};

struct DIR;
typedef struct DIR DIR;

#if __BSD_VISIBLE

/*
 * File types
 */
#define DT_UNKNOWN       0
#define DT_DIR           4
#define DT_REG           8

#endif /* __BSD_VISIBLE */

__END_DECLS

#endif /*_SYS_DIRENT_H_*/
