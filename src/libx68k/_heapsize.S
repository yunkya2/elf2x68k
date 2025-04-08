/*
 * Heap size definition
 */

#include "config.h"

	.data

.global _heap_size
_heap_size:
	.long	HEAP_SIZE

	.end
