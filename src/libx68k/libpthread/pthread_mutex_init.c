/*
 *  pthread_mutex_init()
 */

#include "pthread_internal.h"

int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutexattr_t *attr)
{
    *mutex = PTHREAD_MUTEX_INITIALIZER;
    return 0;
}
