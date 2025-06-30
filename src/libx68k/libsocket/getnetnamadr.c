/*
 * getnetbyname()
 * getnetbyaddr()
 */

#include <stdlib.h>
#include <netdb.h>
#include <errno.h>
#include "tcpipdrv.h"

struct netent *getnetbyname(const char *name)
{
    _ti_func func = __sock_search_ti_entry();

    if (!func) {
        return NULL;
    }

    return (struct netent *)func(_TI_getnetbyname, (long *)name);
}

struct netent *getnetbyaddr(unsigned long net, int type)
{
    _ti_func func = __sock_search_ti_entry();

    if (!func) {
        return NULL;
    }

    long arg[2];

    arg[0] = net;
    arg[1] = type;

    return (struct netent *)func(_TI_getnetbyaddr, arg);
}
