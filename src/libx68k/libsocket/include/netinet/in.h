#ifndef _NETINET_IN_H_
#define _NETINET_IN_H_

#include <sys/cdefs.h>
#include <stdint.h>
#include <sys/socket.h>

__BEGIN_DECLS

typedef uint32_t in_addr_t;
struct in_addr
{
  in_addr_t s_addr;
};

typedef uint16_t in_port_t;
struct sockaddr_in
{
  short sin_family;
  in_port_t sin_port;
  struct in_addr sin_addr;
  char sin_zero[8];
};

#define INADDR_ANY          ((in_addr_t)0x00000000)
#define INADDR_BROADCAST    ((in_addr_t)0xffffffff)
#define INADDR_NONE         ((in_addr_t)0xffffffff)
#define INET_ADDRSTRLEN 16

#include <sys/endian.h>

#define htonl(x)  htobe32(x)
#define htons(x)  htobe16(x)
#define ntohl(x)  be32toh(x)
#define ntohs(x)  be16toh(x)

__END_DECLS

#endif /* _NETINET_IN_H_ */
