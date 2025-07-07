/*
 *  pthread_rwlock_destroy()
 */

#include "pthread_internal.h"

int pthread_rwlock_destroy(pthread_rwlock_t *lock)
{
    if (!lock->is_initialized) {
        return EINVAL;
    }
    if (lock->count != 0) {
        return EBUSY;
    }
    lock->is_initialized = 0;
    return 0;
}
