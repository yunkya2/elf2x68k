/*
 *  pthread_setcancelstate()
 */

#include "pthread_internal.h"

int pthread_setcancelstate(int state, int *oldstate)
{
    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return ESRCH;  // Current thread not found
    }

    if (oldstate) {
        *oldstate = (pi->stat & PTH_STAT_CANCEL_DISABLE) ? PTHREAD_CANCEL_DISABLE : PTHREAD_CANCEL_ENABLE;
    }

    if (state == PTHREAD_CANCEL_ENABLE) {
        pi->stat &= ~PTH_STAT_CANCEL_DISABLE;
    } else if (state == PTHREAD_CANCEL_DISABLE) {
        pi->stat |= PTH_STAT_CANCEL_DISABLE;
    } else {
        return EINVAL;  // Invalid state
    }
    return 0;
}
