/*
 *  pthread_rwlock_unlock()
 */

#include "pthread_internal.h"

int pthread_rwlock_unlock(pthread_rwlock_t *lock)
{
    if (!lock->is_initialized) {
        return EINVAL;
    }

    int ssp = _pthread_enter_critical();
    if (lock->count > 0) {
        // Unlock reader lock
        lock->count--;
        if (lock->count == 0) {
            if (lock->wr_waiting) {
             // Wake up the first waiting writer thread
                pthread_internal_t *wakeup = lock->wr_waiting;
                lock->wr_waiting = wakeup->waitnext;
                wakeup->waitnext = NULL;
                wakeup->stat &= ~PTH_STAT_WAITING;
                _dos_send_pr(0, wakeup->tid, 0xfffb, NULL, 0);
            }
        }
    } else if (lock->count < 0) {
        // Unlock writer lock
        lock->count++;
        if (lock->wr_waiting) {
            // Wake up the first waiting writer thread
            pthread_internal_t *wakeup = lock->wr_waiting;
            lock->wr_waiting = wakeup->waitnext;
            wakeup->waitnext = NULL;
            wakeup->stat &= ~PTH_STAT_WAITING;
            _dos_send_pr(0, wakeup->tid, 0xfffb, NULL, 0);
        } else if (lock->count == 0) {
            // Wake up all waiting reader threads
            while (lock->rd_waiting) {
                pthread_internal_t *wakeup = lock->rd_waiting;
                lock->rd_waiting = wakeup->waitnext;
                wakeup->waitnext = NULL;
                wakeup->stat &= ~PTH_STAT_WAITING;
                _dos_send_pr(0, wakeup->tid, 0xfffb, NULL, 0);
            }
        }
    } else {
        _pthread_leave_critical(ssp);
        return EINVAL;
    }
    _pthread_leave_critical(ssp);
    _dos_change_pr();

    return 0;
}
