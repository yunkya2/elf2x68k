/*
 * getprotobyname()
 * getprotobynumber()
 */

#include <stdlib.h>
#include <netdb.h>
#include <errno.h>
#include "tcpipdrv.h"

struct protoent *getprotobyname(const char *name)
{
    _ti_func func = _search_ti_entry();

    if (!func) {
        return NULL;
    }

    return (struct protoent *)func(_TI_getprotobyname, (long *)name);
}

struct protoent *getprotobynumber(int proto)
{
    _ti_func func = _search_ti_entry();

    if (!func) {
        return NULL;
    }

    return (struct protoent *)func(_TI_getprotobynumber, (long *)proto);
}
