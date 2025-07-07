/*
 *  pthread_spin_unlock()
 */

#include "pthread_internal.h"

int pthread_spin_unlock(pthread_spinlock_t *lock)
{
    lock->lock = 0;
    return 0;
}
