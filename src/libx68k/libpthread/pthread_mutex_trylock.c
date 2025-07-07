/*
 *  pthread_mutex_trylock()
 */

#include "pthread_internal.h"

int pthread_mutex_trylock(pthread_mutex_t *mutex)
{
    if (!mutex->is_initialized) {
        return EINVAL;
    }

    int ssp = _pthread_enter_critical();
    int res = (mutex->mutex == 0x00) ? 0 : EBUSY;
    mutex->mutex = 0x80;
    _pthread_leave_critical(ssp);
    return res;
}
