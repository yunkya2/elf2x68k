/*
 *  pthread_yield()
 */

#include "pthread_internal.h"

void pthread_yield(void)
{
    _dos_change_pr();
}
