/*
 *  inet_ntoa()
 *  inet_ntop()
 */

#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

char *inet_ntoa(struct in_addr in)
{
    static char buffer[INET_ADDRSTRLEN];
    snprintf(buffer, sizeof(buffer), "%d.%d.%d.%d", 
             (in.s_addr >> 24) & 0xFF,
             (in.s_addr >> 16) & 0xFF,
             (in.s_addr >> 8) & 0xFF,
             in.s_addr & 0xFF);
    return buffer;
}

const char *inet_ntop(int af, const void *src, char *dst, socklen_t size)
{
    switch (af) {
    case AF_INET:
        struct in_addr addr;
        if (size < INET_ADDRSTRLEN) {
            errno = ENOSPC; // Not enough space
            return NULL;
        }
        addr = *(struct in_addr *)src;
        snprintf(dst, size, "%d.%d.%d.%d", 
                 (addr.s_addr >> 24) & 0xFF,
                 (addr.s_addr >> 16) & 0xFF,
                 (addr.s_addr >> 8) & 0xFF,
                 addr.s_addr & 0xFF);
        return dst;
    default:
        errno = EAFNOSUPPORT; // Address family not supported
        return NULL;
    }
}
