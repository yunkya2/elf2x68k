/*
 *  inet_addr()
 *  inet_aton()
 *  inet_pton()
 */

#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int inet_aton(const char *cp, struct in_addr *inp)
{
    char *ncp;
    in_addr_t in = 0;

    for (int i = 24; i >= 0; i -= 8) {
        in |= strtoul(cp, &ncp, 0);
        if (cp == ncp) {
            return 0;
        }
        cp = ncp;
        if (*cp != '.') {
            break;
        }
        cp++;
        in = (in & 0xffffff00) | ((in & 0xff) << i);
    }
    if (*cp != '\0') {
        return 0;
    }
    inp->s_addr = htonl(in);
    return 1;
}

in_addr_t inet_addr(const char *cp)
{
    struct in_addr ina;
    if (!inet_aton(cp, &ina)) {
        return INADDR_NONE;
    }
    return ina.s_addr;
}

int inet_pton(int af, const char *src, void *dst)
{
    switch (af) {
    case AF_INET:
        return inet_aton(src, (struct in_addr *)dst);
    default:
        errno = EAFNOSUPPORT; // Address family not supported
        return -1;
    }
}
