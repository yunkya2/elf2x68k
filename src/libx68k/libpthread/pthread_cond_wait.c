/*
 *  pthread_cond_wait()
 */

 #include "pthread_internal.h"

int	pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex)
{
    if (!cond->is_initialized || !mutex->is_initialized) {
        return EINVAL;
    }

    pthread_internal_t *pi = __pthread_self_internal();

    __pthread_testcancel(pi);

    int ssp = _pthread_enter_critical();

    // mutexを解放する
    mutex->mutex = 0;
    if (mutex->waiting) {
        // Wake up the first waiting thread
        pthread_internal_t *wakeup = mutex->waiting;
        mutex->waiting = wakeup->waitnext;
        wakeup->waitnext = NULL;
        wakeup->stat &= ~PTH_STAT_WAITING;
        _dos_send_pr(0, wakeup->tid, 0xfffb, NULL, 0);
    }

    // 状態変数で待ちに入る
    if (cond->waiting == NULL) {
        cond->waiting_tail = &cond->waiting;
    }
    *cond->waiting_tail = pi;
    pi->waitnext = NULL;
    cond->waiting_tail = &pi->waitnext;
    pi->stat |= PTH_STAT_WAITING|PTH_STAT_IN_CANCEL_POINT;
    do {
        _dos_change_pr();
    } while (pi->stat & PTH_STAT_WAITING);
    pi->stat &= ~PTH_STAT_IN_CANCEL_POINT;

    // mutexを再度取得する
    if (mutex->mutex != 0x00) {
        if (mutex->waiting == NULL) {
            mutex->waiting_tail = &mutex->waiting;
        }
        *mutex->waiting_tail = pi;
        pi->waitnext = NULL;
        mutex->waiting_tail = &pi->waitnext;
        pi->stat |= PTH_STAT_WAITING;
        do {
            _dos_change_pr();
        } while (mutex->mutex != 0x00);
    }
    mutex->mutex = 0x80;

    _pthread_leave_critical(ssp);

    return 0;
}
