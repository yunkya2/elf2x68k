/*
 *  pthread_attr_getdetachstate()
 */

#include "pthread_internal.h"

int	pthread_attr_getdetachstate(const pthread_attr_t *attr, int *detachstate)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (detachstate) {
        *detachstate = attr->detachstate;
    }

    return 0;
}
