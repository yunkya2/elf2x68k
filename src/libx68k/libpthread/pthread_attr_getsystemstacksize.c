/*
 *  pthread_attr_getsystemstacksize()
 */

#include "pthread_internal.h"

int	pthread_attr_getsystemstacksize(const pthread_attr_t *attr, size_t *stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stacksize) {
        *stacksize = attr->systemstacksize;
    }

    return 0;
}
