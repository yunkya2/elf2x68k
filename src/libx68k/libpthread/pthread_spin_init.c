/*
 *  pthread_spin_init()
 */

#include "pthread_internal.h"

int pthread_spin_init(pthread_spinlock_t *lock, int pshared)
{
    *lock = (pthread_spinlock_t){ 0 };
    return 0;
}
