/*
 *  pthread_rwlock_tryrdlock()
 */

 #include "pthread_internal.h"

int	pthread_rwlock_tryrdlock(pthread_rwlock_t *lock)
{
    if (!lock->is_initialized) {
        return EINVAL;
    }

    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return ESRCH;  // Current thread not found
    }

    int ssp = _pthread_enter_critical();
    if (lock->count < 0) {
        _pthread_leave_critical(ssp);
        return EBUSY;
    }
    lock->count++;      // Own the reader lock
    _pthread_leave_critical(ssp);

    return 0;
}
