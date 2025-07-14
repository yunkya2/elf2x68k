/*
 *  pthread_barrier_wait()
 */

 #include "pthread_internal.h"

int	pthread_barrier_wait(pthread_barrier_t *barrier)
{
    if (!barrier->is_initialized) {
        return EINVAL;
    }

    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return ESRCH;  // Current thread not found
    }

    int ssp = _pthread_enter_critical();
    int res = 0;

    if (++barrier->nwaiting >= barrier->count) {
        barrier->nwaiting = 0;
        while (barrier->waiting) {
            // Wake up all waiting threads
            pthread_internal_t *wakeup = barrier->waiting;
            barrier->waiting = wakeup->waitnext;
            wakeup->waitnext = NULL;
            wakeup->stat &= ~PTH_STAT_WAITING;
            _dos_send_pr(0, wakeup->tid, 0xfffb, NULL, 0);
        }
        res = PTHREAD_BARRIER_SERIAL_THREAD;
    } else {
        if (barrier->waiting == NULL) {
            barrier->waiting_tail = &barrier->waiting;
        }
        *barrier->waiting_tail = pi;
        pi->waitnext = NULL;
        barrier->waiting_tail = &pi->waitnext;
        pi->stat |= PTH_STAT_WAITING;
        do {
            _dos_change_pr();
        } while (pi->stat & PTH_STAT_WAITING);
    }

    _pthread_leave_critical(ssp);
    return res;
}
