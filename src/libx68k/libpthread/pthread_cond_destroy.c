/*
 *  pthread_cond_destroy()
 */

#include "pthread_internal.h"

int pthread_cond_destroy(pthread_cond_t *cond)
{
    if (!cond->is_initialized) {
        return EINVAL;
    }
    if (cond->waiting) {
        return EBUSY;
    }
    cond->is_initialized = 0;
    return 0;
}
