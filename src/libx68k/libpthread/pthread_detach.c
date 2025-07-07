/*
 *  pthread_detach()
 */

#include "pthread_internal.h"

 int pthread_detach(pthread_t thread)
{
    pthread_internal_t *pi = __pthread_tid_internal(thread);

    if (pi == NULL) {
        return ESRCH;   // Thread does not exist
    }
    if (pi->stat & (PTH_STAT_DETACHED|PTH_STAT_TERMINATED)) {
        return EINVAL;  // Thread is already detached or terminated
    }

    pi->stat |= PTH_STAT_DETACHED;
    return 0;
}
