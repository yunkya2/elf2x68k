/*
 *  pthread_mutex_lock()
 */

#include "pthread_internal.h"

int pthread_mutex_lock(pthread_mutex_t *mutex)
{
    if (!mutex->is_initialized) {
        return EINVAL;
    }

    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return ESRCH;  // Current thread not found
    }

    int ssp = _pthread_enter_critical();
    if (mutex->mutex != 0x00) {
        if (mutex->waiting == NULL) {
            mutex->waiting_tail = &mutex->waiting;
        }
        *mutex->waiting_tail = pi;
        pi->waitnext = NULL;
        mutex->waiting_tail = &pi->waitnext;
        pi->stat |= PTH_STAT_WAITING;
        do {
            _dos_change_pr();
        } while (mutex->mutex != 0x00);
    }
    mutex->mutex = 0x80;
    _pthread_leave_critical(ssp);
    return 0;
}
