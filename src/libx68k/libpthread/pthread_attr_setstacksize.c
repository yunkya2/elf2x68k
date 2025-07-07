/*
 *  pthread_attr_setstacksize()
 */

#include "pthread_internal.h"

int	pthread_attr_setstacksize(pthread_attr_t *attr, size_t stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stacksize == 0) {
        return EINVAL;
    }

    attr->stacksize = stacksize;

    return 0;
}
