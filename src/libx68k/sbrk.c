/*
 * sbrk()
 */

#include <x68k/dos.h>
#include <unistd.h>
#include <errno.h>

int __doserr2errno(int error);

void *sbrk(ptrdiff_t incr)
{
  extern char *_HSTA, *_HEND;     /* Set by linker.  */
  static char *heap_end;
  char *new_heap_end;
  char *prev_heap_end;

  if (heap_end == 0)
    heap_end = _HSTA;
 
  prev_heap_end = heap_end;
  new_heap_end = heap_end + incr;

  if (new_heap_end > _HEND) {
    char *new_block_end;
    extern char *_PSP;
    int res;

    /* Extend the memory block for heap */

    new_block_end = (char *)(((uint32_t)new_heap_end + 0x3fff) & ~0x3fff);
    res = _dos_setblock(_PSP, (uint32_t)new_block_end - (uint32_t)_PSP);

    if (res < 0) {
      errno = ENOMEM;
      return (void *)-1;
    }

    _HEND = new_block_end;
  }

  heap_end = new_heap_end;

  return (void *)prev_heap_end;
}
