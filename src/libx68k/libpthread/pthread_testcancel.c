/*
 *  pthread_testcancel()
 */

#include "pthread_internal.h"

void __pthread_testcancel(pthread_internal_t *pi)
{
    if ((pi->stat & PTH_STAT_DEFEREED_CANCELED)) {
        __pthread_key_call_destructors(pi);
        __pthread_call_all_cleanup(pi);
        pi->stat &= ~PTH_STAT_DEFEREED_CANCELED;
        pi->stat |= PTH_STAT_CANCELED;
        if (_dos_suspend_pr(pi->tid) < 0) {
            // 対象が自分自身だった場合
            while (1) {
                _dos_change_pr();
            }
        }
    }
}

void pthread_testcancel(void)
{
    pthread_internal_t *pi = __pthread_self_internal(); 
    if (pi == NULL || (pi->stat & PTH_STAT_TERMINATED)) {
        return;  // Current thread not found
    }
    return __pthread_testcancel(pi);
}
