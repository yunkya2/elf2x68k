/*
 *  pthread_mutexattr_init()
 *  pthread_mutexattr_destroy()
 *  pthread_mutexattr_gettype()
 *  pthread_mutexattr_settype()
 */

#include "pthread_internal.h"

int pthread_mutexattr_init(pthread_mutexattr_t *attr)
{
    attr->type = PTHREAD_MUTEX_NORMAL;
    return 0;
}

int pthread_mutexattr_destroy(pthread_mutexattr_t *attr)
{
    return 0;
}

int pthread_mutexattr_gettype(const pthread_mutexattr_t *attr, int *kind)
{
    *kind = attr->type;
    return 0;
}

int pthread_mutexattr_settype(pthread_mutexattr_t *attr, int kind)
{
    attr->type = kind;
    return 0;
}
