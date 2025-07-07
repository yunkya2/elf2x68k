/*
 *  pthread_attr_getsystemstack()
 */

#include "pthread_internal.h"

int	pthread_attr_getsystemstack(const pthread_attr_t *attr, void **stackaddr, size_t *stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stackaddr) {
        *stackaddr = attr->systemstackaddr;
    }
    if (stacksize) {
        *stacksize = attr->systemstacksize;
    }

    return 0;
}
