/*
 *  pthread_attr_setsystemstack()
 */

#include "pthread_internal.h"

int	pthread_attr_setsystemstack(pthread_attr_t *attr, void *stackaddr, size_t stacksize)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (stackaddr == NULL || stacksize == 0) {
        return EINVAL;
    }

    attr->systemstackaddr = stackaddr;
    attr->systemstacksize = stacksize;

    return 0;
}
