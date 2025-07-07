/*
 *  pthread_spin_lock()
 */

#include "pthread_internal.h"

int pthread_spin_lock(pthread_spinlock_t *lock)
{
    int val;
    while (1) {
        __asm__ volatile(
            "moveq.l #0,%0\n"
            "tas     %1\n"
            "beqs    1f\n"
            "addq.l  #1,%0\n"
            "1:\n"
        : "=d"(val) : "m"(lock->lock) : "memory");
        if (!val) {
            break;
        }
        _dos_change_pr();
    }
    return 0;
}
