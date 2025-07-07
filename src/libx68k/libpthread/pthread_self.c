/*
 *  pthread_self()
 */

#include "pthread_internal.h"

pthread_t pthread_self(void)
{
    struct dos_prcptr prc;
    int tid = _dos_get_pr(-2, &prc);
    return tid >= 0 ? (pthread_t)tid : (pthread_t)-1;
}
