/*
 *  pthread_mutex_destroy()
 */

#include "pthread_internal.h"

int pthread_mutex_destroy(pthread_mutex_t *mutex)
{
    if (!mutex->is_initialized) {
        return EINVAL;
    }
    if (mutex->mutex) {
        return EBUSY;
    }
    mutex->is_initialized = 0;
    return 0;
}
