/*
 *  pthread_cond_broadcast()
 */

#include "pthread_internal.h"

int	pthread_cond_broadcast(pthread_cond_t *cond)
{
    if (!cond->is_initialized) {
        return EINVAL;
    }

    int ssp = _pthread_enter_critical();
    while (cond->waiting) {
        // Wake up all waiting threads
        pthread_internal_t *wakeup = cond->waiting;
        cond->waiting = wakeup->waitnext;
        wakeup->waitnext = NULL;
        wakeup->stat &= ~PTH_STAT_WAITING;
        _dos_send_pr(0, wakeup->tid, 0xfffb, NULL, 0);
    }
    _pthread_leave_critical(ssp);

    return 0;
}
