/*
 *  poll()
 */

#include <stdlib.h>
#include <poll.h>
#include <errno.h>
#include "tcpipdrv.h"
#include <x68k/dos.h>

static int socklen(_ti_func func, int fd, int mode)
{
    long arg[2];

    arg[0] = fd;
    arg[1] = mode;

    return func(_TI_socklen, arg);
}

int poll(struct pollfd *fds, nfds_t nfds, int timeout)
{
    _ti_func func = _search_ti_entry();

    if (!func) {
        errno = ENOSYS;
        return -1;
    }

    if (fds == NULL || nfds == 0) {
        errno = EINVAL;
        return -1;
    }

    long t0 = _dos_time_pr();

    while (1) {
        int nevents = 0;
        for (nfds_t i = 0; i < nfds; i++) {
            fds[i].revents = 0;
            if (fds[i].events & POLLIN) {
                int r = socklen(func, fds[i].fd, 0);
                if (r > 0) {
                    fds[i].revents |= POLLIN;
                } else if (r < 0) {
                    fds[i].revents |= POLLERR;
                }
            }
            if (fds[i].events & POLLOUT) {
                int r = socklen(func, fds[i].fd, 1);
                if (r == 0) {
                    fds[i].revents |= POLLOUT;
                } else if (r < 0) {
                    fds[i].revents |= POLLERR;
                }
            }
            if (fds[i].revents != 0) {
                nevents++;
            }
        }
        if (nevents > 0) {
            return nevents;
        }

        long elapsed = _dos_time_pr() - t0;
        if (timeout >= 0 && elapsed >= timeout) {
            return 0;
        }

        _dos_sleep_pr(10);
    }
}
