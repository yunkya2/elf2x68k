/*
 *  pthread_rwlock_wrlock()
 */

 #include "pthread_internal.h"

int	pthread_rwlock_wrlock(pthread_rwlock_t *lock)
{
    if (!lock->is_initialized) {
        return EINVAL;
    }

    pthread_internal_t *pi = __pthread_self_internal();

    int ssp = _pthread_enter_critical();
    while (lock->count != 0) {
        // Reader or writer locked
        if (lock->wr_waiting == NULL) {
            lock->wr_waiting_tail = &lock->wr_waiting;
        }
        *lock->wr_waiting_tail = pi;
        pi->waitnext = NULL;
        lock->wr_waiting_tail = &pi->waitnext;
        pi->stat |= PTH_STAT_WAITING;
        do {
            _dos_change_pr();
        } while (pi->stat & PTH_STAT_WAITING);
    }
    lock->count--;      // Own the writer lock
    _pthread_leave_critical(ssp);

    return 0;
}
