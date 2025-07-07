/*
 *  pthread_attr_getstack()
 */

#include "pthread_internal.h"

int	pthread_attr_getstack(const pthread_attr_t *attr, void **stackaddr, size_t *stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stackaddr) {
        *stackaddr = attr->stackaddr;
    }
    if (stacksize) {
        *stacksize = attr->stacksize;
    }

    return 0;
}
