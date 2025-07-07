/*
 *  pthread_cancel()
 */

#include "pthread_internal.h"

int pthread_cancel(pthread_t thread)
{
    pthread_internal_t *pi = __pthread_tid_internal(thread);

    if (pi == NULL || (pi->stat & PTH_STAT_TERMINATED)) {
        return ESRCH;   // Thread does not exist
    }

    if (!(pi->stat & (PTH_STAT_CANCELED|PTH_STAT_CANCEL_DISABLE))) {
        pi->stat |= PTH_STAT_DEFEREED_CANCELED;
        if (pi->stat & (PTH_STAT_CANCEL_ASYNC|PTH_STAT_IN_CANCEL_POINT)) {
            __pthread_testcancel(pi);
        }
    }
    return 0;
}
