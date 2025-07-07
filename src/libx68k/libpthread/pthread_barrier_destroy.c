/*
 *  pthread_barrier_destroy()
 */

#include "pthread_internal.h"

int pthread_barrier_destroy(pthread_barrier_t *barrier)
{
    if (!barrier->is_initialized) {
        return EINVAL;
    }
    if (barrier->waiting) {
        return EBUSY;
    }
    barrier->is_initialized = 0;
    return 0;
}
