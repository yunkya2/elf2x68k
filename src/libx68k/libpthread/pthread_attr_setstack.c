/*
 *  pthread_attr_setstack()
 */

#include "pthread_internal.h"

int	pthread_attr_setstack(pthread_attr_t *attr, void *stackaddr, size_t stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stackaddr == NULL || stacksize == 0) {
        return EINVAL;
    }

    attr->stackaddr = stackaddr;
    attr->stacksize = stacksize;

    return 0;
}
