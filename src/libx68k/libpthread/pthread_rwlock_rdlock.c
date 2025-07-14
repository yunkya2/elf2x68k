/*
 *  pthread_rwlock_rdlock()
 */

 #include "pthread_internal.h"

int	pthread_rwlock_rdlock(pthread_rwlock_t *lock)
{
    if (!lock->is_initialized) {
        return EINVAL;
    }

    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return ESRCH;  // Current thread not found
    }

    int ssp = _pthread_enter_critical();
    while (lock->count < 0) {
        // Writer locked
        if (lock->rd_waiting == NULL) {
            lock->rd_waiting_tail = &lock->rd_waiting;
        }
        *lock->rd_waiting_tail = pi;
        pi->waitnext = NULL;
        lock->rd_waiting_tail = &pi->waitnext;
        pi->stat |= PTH_STAT_WAITING;
        do {
            _dos_change_pr();
        } while (pi->stat & PTH_STAT_WAITING);
    }
    lock->count++;      // Own the reader lock
    _pthread_leave_critical(ssp);

    return 0;
}
