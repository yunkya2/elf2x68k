/*
 *  pthread_attr_getstacksize()
 */

#include "pthread_internal.h"

int	pthread_attr_getstacksize(const pthread_attr_t *attr, size_t *stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stacksize) {
        *stacksize = attr->stacksize;
    }

    return 0;
}
