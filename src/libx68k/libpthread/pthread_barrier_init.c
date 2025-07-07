/*
 *  pthread_barrier_init()
 */

#include "pthread_internal.h"

int pthread_barrier_init(pthread_barrier_t *barrier, const pthread_barrierattr_t *attr, unsigned count)
{
    if (count == 0) {
        return EINVAL;
    }

    *barrier = (pthread_barrier_t){ .is_initialized = 1, .count = count };
    return 0;
}
