#ifndef _POLL_H_
#define _POLL_H_

#include <sys/cdefs.h>

__BEGIN_DECLS

#define POLLIN      0x0001
#define POLLPRI     0x0002
#define POLLOUT     0x0004
#define POLLERR     0x0008
#define POLLHUP     0x0010
#define POLLNVAL    0x0020

struct pollfd {
    int fd;
    short int events;
    short int revents;
};

typedef unsigned long int nfds_t;

int poll(struct pollfd *fds, nfds_t nfds, int timeout);

__END_DECLS

#endif /* _POLL_H_ */
