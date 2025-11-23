/*
 * sbrk() (without Human68k)
 */

#include <unistd.h>
#include <errno.h>

int __doserr2errno(int error);

void *sbrk(ptrdiff_t incr)
{
  extern char *_HSTA, *_HEND;     /* Set by linker.  */
  static char *heap_end;
  char *new_heap_end;
  char *prev_heap_end;

  if (heap_end == 0) {
    if (_HSTA == 0) {             /* in the case of "-nostartfiles" */
      extern char _end;
      extern int _heap_size;
      _HSTA = &_end;
      _HEND = _HSTA + _heap_size;
    }
    heap_end = _HSTA;
  }
 
  prev_heap_end = heap_end;
  new_heap_end = heap_end + incr;

  if (new_heap_end > _HEND) {
    errno = ENOMEM;
    return (void *)-1;
  }

  heap_end = new_heap_end;

  return (void *)prev_heap_end;
}
