/*
 *  pthread_mutex_unlock()
 */

#include "pthread_internal.h"

int pthread_mutex_unlock(pthread_mutex_t *mutex)
{
    if (!mutex->is_initialized) {
        return EINVAL;
    }

    int ssp = _pthread_enter_critical();
    mutex->mutex = 0;
    if (mutex->waiting) {
        // Wake up the first waiting thread
        pthread_internal_t *wakeup = mutex->waiting;
        mutex->waiting = wakeup->waitnext;
        wakeup->waitnext = NULL;
        wakeup->stat &= ~PTH_STAT_WAITING;
        _dos_send_pr(0, wakeup->tid, 0xfffb, NULL, 0);
    }
    _pthread_leave_critical(ssp);
    _dos_change_pr(); // send_prだけではスケジューリングされない

    return 0;
}
