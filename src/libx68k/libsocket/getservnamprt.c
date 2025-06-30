/*
 * getservbyname()
 * getservbyport()
 */

#include <stdlib.h>
#include <netdb.h>
#include <errno.h>
#include "tcpipdrv.h"

struct servent *getservbyname(const char *name, const char *proto)
{
    _ti_func func = __sock_search_ti_entry();

    if (!func) {
        return NULL;
    }

    long arg[2];

    arg[0] = (long)name;
    arg[1] = (long)proto;

    return (struct servent *)func(_TI_getservbyname, arg);
}

struct servent *getservbyport(int port, const char *proto)
{
    _ti_func func = __sock_search_ti_entry();

    if (!func) {
        return NULL;
    }

    long arg[2];

    arg[0] = port;
    arg[1] = (long)proto;

    return (struct servent *)func(_TI_getservbyport, arg);
}
