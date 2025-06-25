#ifndef _ARPA_INET_H_
#define _ARPA_INET_H_

#include <sys/cdefs.h>
#include <netinet/in.h>

__BEGIN_DECLS

in_addr_t inet_addr(const char *);
int inet_aton(const char *, struct in_addr *);
int inet_pton(int, const char *, void *);

char *inet_ntoa(struct in_addr);
const char *inet_ntop(int, const void *, char *, socklen_t);

/* following functions are not implemented */
int inet_net_ntop(int, const void *, int, char *, size_t);
int inet_net_pton(int, const char *, void *, size_t);
in_addr_t inet_network(const char *);
in_addr_t inet_lnaof(struct in_addr);
in_addr_t inet_netof(struct in_addr);
struct in_addr inet_makeaddr(in_addr_t, in_addr_t);

__END_DECLS

#endif /* _ARPA_INET_H_ */
