/*
 * sbrk()
 */

#include <unistd.h>

void *sbrk(ptrdiff_t incr)
{
   extern char * _HSTA; /* Set by linker.  */
   static char * heap_end;
   char *        prev_heap_end;

   if (heap_end == 0)
     heap_end = _HSTA;

   prev_heap_end = heap_end;
   heap_end += incr;

   return (void *) prev_heap_end;
}
