/*
 *  pthread_attr_setsystemstack_np()
 */

#include "pthread_internal.h"

int	pthread_attr_setsystemstack_np(pthread_attr_t *attr, void *stackaddr, size_t stacksize)
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
