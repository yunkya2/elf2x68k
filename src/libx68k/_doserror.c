/*
 * Convert Human68K DOS errors to libc error
 */

#include "config.h"
#include <errno.h>

static const char errmap[] = {
  0,          /*   0: */
  ENOENT,     /*  -1: Illegal function code */
  ENOENT,     /*  -2: File not found */
  ENOENT,     /*  -3: Directory not found */
  EMFILE,     /*  -4: Too many open files */
  EISDIR,     /*  -5: Cannot access directory or volume label */
  EBADF,      /*  -6: Bad file descriptor */
  EFAULT,     /*  -7: Broken memory management area */
  ENOMEM,     /*  -8: No memory */
  EFAULT,     /*  -9: Illegal memory management pointer */
  EFAULT,     /* -10: Illegal environment */
  ENOEXEC,    /* -11: Illegal execute file format */
  EINVAL,     /* -12: Illegal access mode */
  ENOENT,     /* -13: Illegal file name */
  EINVAL,     /* -14: Illegal parameter */
  EXDEV,      /* -15: Illegal drive name */
  ENOTEMPTY,  /* -16: Cannot remove current directory */
  EPERM,      /* -17: Not supported ioctl */
  ENOENT,     /* -18: No directory entry */
  EACCES,     /* -19: Read only file */
  EEXIST,     /* -20: Directory already exists */
  ENOTEMPTY,  /* -21: Directory is not emptry */
  EPERM,      /* -22: Cannot rename the file */
  ENOSPC,     /* -23: Disk full */
  ENOSPC,     /* -24: Directory full */
  ESPIPE,     /* -25: Cannot seek */
  EPERM,      /* -26: Already in the supervisor state */
  ETXTBSY,    /* -27: Duplicate thread name */
  EIO,        /* -28: Cannot send */
  EPERM,      /* -29: Thread full */
  ENOSYS,     /* -30: */
  ENOSYS,     /* -31: */
  ENFILE,     /* -32: Lock region full */
  ENOLCK,     /* -33: File is locked */
  EACCES,     /* -34: Drive busy */
  ELOOP,      /* -35: Symbolic link loop */
};

int __doserr2errno(int error)
{
  if ((error >= 0) && (error <= sizeof(errmap)))
    return errmap[error];

  return EINVAL;
}
