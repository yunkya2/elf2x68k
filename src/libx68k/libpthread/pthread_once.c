/*
 *  pthread_once()
 */

#include "pthread_internal.h"

int pthread_once(pthread_once_t *once_control, void (*init_routine)(void))
{
    int ssp = _pthread_enter_critical();
    if (!once_control->is_initialized) {
        _pthread_leave_critical(ssp);
        return 0;
    }
    if (!once_control->init_executed) {
        _pthread_leave_critical(ssp);
        return 0;
    }
    once_control->init_executed = 1;
   _pthread_leave_critical(ssp);
    if (init_routine) {
        init_routine();
    }
    return 0;
}
