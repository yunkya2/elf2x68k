/*
 * Stack size definition
 */

#include "config.h"

	.data

.global _stack_size
_stack_size:
	.long	STACK_SIZE

	.end
