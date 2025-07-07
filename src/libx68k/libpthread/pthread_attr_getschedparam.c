/*
 *  pthread_attr_getschedparam()
 */

#include "pthread_internal.h"

int	pthread_attr_getschedparam(const pthread_attr_t *attr, struct sched_param *param)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    if (param) {
        param->sched_priority = attr->priority;
    }

    return 0;
}
