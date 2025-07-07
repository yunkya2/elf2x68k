/*
 *  pthread_setcanceltype()
 */

#include "pthread_internal.h"

int pthread_setcanceltype(int type, int *oldtype)
{
    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return ESRCH;  // Current thread not found
    }

    if (oldtype) {
        *oldtype = (pi->stat & PTH_STAT_CANCEL_ASYNC) ? PTHREAD_CANCEL_ASYNCHRONOUS : PTHREAD_CANCEL_DEFERRED;
    }

    if (type == PTHREAD_CANCEL_ASYNCHRONOUS) {
        pi->stat |= PTH_STAT_CANCEL_ASYNC;
    } else if (type == PTHREAD_CANCEL_DEFERRED) {
        pi->stat &= ~PTH_STAT_CANCEL_ASYNC;
    } else {
        return EINVAL;  // Invalid type
    }
    return 0;
}
