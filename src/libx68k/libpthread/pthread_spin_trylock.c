/*
 *  pthread_spin_trylock()
 */

#include "pthread_internal.h"

int pthread_spin_trylock(pthread_spinlock_t *lock)
{
    int val;
    __asm__ volatile(
        "moveq.l #0,%0\n"
        "tas     %1\n"
        "beqs    1f\n"
        "addq.l  #1,%0\n"
        "1:\n"
    : "=d"(val) : "m"(lock->lock) : "memory");
    return val ? EBUSY : 0;
}
