/*
 *  pthread_cond_init()
 */

#include "pthread_internal.h"

int pthread_cond_init(pthread_cond_t *cond, const pthread_condattr_t *attr)
{
    *cond = PTHREAD_COND_INITIALIZER;
    return 0;
}
