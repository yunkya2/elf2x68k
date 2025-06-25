/*
 *  shutdown()
 */

#include <sys/socket.h>
#include <errno.h>
#include "tcpipdrv.h"

int shutdown(int sockfd, int how)
{
    _ti_func func = _search_ti_entry ();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    long arg[2];
    int res;

    arg[0] = sockfd;
    arg[1] = how;

    res = func(_TI_shutdown, arg);
    if (res < 0) {
        errno = EIO;
        return res;
    }
    return res;
}
