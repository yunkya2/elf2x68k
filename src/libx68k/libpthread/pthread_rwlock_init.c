/*
 *  pthread_rwlock_init()
 */

#include "pthread_internal.h"

int pthread_rwlock_init(pthread_rwlock_t *lock, const pthread_rwlockattr_t *attr)
{
    *lock = PTHREAD_RWLOCK_INITIALIZER;
    return 0;
}
