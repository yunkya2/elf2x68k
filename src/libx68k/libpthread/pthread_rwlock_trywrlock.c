/*
 *  pthread_rwlock_trywrlock()
 */

 #include "pthread_internal.h"

int	pthread_rwlock_trywrlock(pthread_rwlock_t *lock)
{
    if (!lock->is_initialized) {
        return EINVAL;
    }

    pthread_internal_t *pi = __pthread_self_internal();

    int ssp = _pthread_enter_critical();
    if (lock->count != 0) {
        _pthread_leave_critical(ssp);
        return EBUSY;
    }
    lock->count--;      // Own the writer lock
    _pthread_leave_critical(ssp);

    return 0;
}
