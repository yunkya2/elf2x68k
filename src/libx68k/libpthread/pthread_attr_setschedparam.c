/*
 *  pthread_attr_setschedparam()
 */

#include "pthread_internal.h"

int	pthread_attr_setschedparam(pthread_attr_t *attr, const struct sched_param *param)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    attr->priority = param->sched_priority;

    return 0;
}
