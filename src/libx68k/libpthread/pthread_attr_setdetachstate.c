/*
 *  pthread_attr_setdetachstate()
 */

#include "pthread_internal.h"

int	pthread_attr_setdetachstate(pthread_attr_t *attr, int detachstate)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    attr->detachstate = detachstate;

    return 0;
}
