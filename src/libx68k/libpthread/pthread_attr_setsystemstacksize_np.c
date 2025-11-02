/*
 *  pthread_attr_setsystemstacksize_np()
 */

#include "pthread_internal.h"

int	pthread_attr_setsystemstacksize_np(pthread_attr_t *attr, size_t stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stacksize == 0) {
        return EINVAL;
    }

    attr->systemstacksize = stacksize;

    return 0;
}
