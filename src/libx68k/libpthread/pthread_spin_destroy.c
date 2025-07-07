/*
 *  pthread_spin_destroy()
 */

#include "pthread_internal.h"

int pthread_spin_destroy(pthread_spinlock_t *lock)
{
    if (lock->lock) {
        return EBUSY;
    }
    return 0;
}
