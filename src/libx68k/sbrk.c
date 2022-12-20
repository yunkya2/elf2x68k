/*
 * sbrk()
 */

#include <unistd.h>

char heap[8192];  /* tentative */

void *sbrk(ptrdiff_t incr)
{
#if 0
   extern char   end; /* Set by linker.  */
   static char * heap_end;
   char *        prev_heap_end;

   if (heap_end == 0)
     heap_end = & end;

   prev_heap_end = heap_end;
   heap_end += incr;

   return (void *) prev_heap_end;
#endif
  return heap;
}
