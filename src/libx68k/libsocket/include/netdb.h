#ifndef _NETDB_H_
#define _NETDB_H_

#include <arpa/inet.h>

__BEGIN_DECLS

struct addrinfo
{
  int ai_flags;
  int ai_family;
  int ai_socktype;
  int ai_protocol;
  socklen_t ai_addrlen;
  struct sockaddr *ai_addr;
  char *ai_canonname;
  struct addrinfo *ai_next;
};

/* ai_flags (not supported) */
#define AI_PASSIVE      0x01
#define AI_CANONNAME    0x02
#define AI_NUMERICHOST  0x04
#define AI_NUMERICSERV  0x08
#define AI_V4MAPPED     0x10
#define AI_ALL          0x20
#define AI_ADDRCONFIG   0x40

/* getaddrinfo() return value */
#define EAI_NONAME      -1
#define EAI_FAIL        -2
#define EAI_MEMORY      -3
#define EAI_BADFLAGS    -4
#define EAI_FAMILY      -5
#define EAI_SOCKTYPE    -6
#define EAI_SERVICE     -7
#define EAI_SYSTEM      -8

int getaddrinfo(const char *node, const char *service,
                const struct addrinfo *hints,
                struct addrinfo **res);
void freeaddrinfo(struct addrinfo *res);
const char *gai_strerror(int);  /* not implemented */

struct hostent
{
  char *h_name;
  char **h_aliases;
  int h_addrtype;
  int h_length;
  char **h_addr_list;
};
#define h_addr  h_addr_list[0]

struct netent
{
  char *n_name;
  char **n_aliases;
  int n_addrtype;
  unsigned long n_net;
};

struct servent {
  char *s_name;
  char **s_aliases;
  int s_port;
  char *s_proto;
};

struct protoent
{
  char *p_name;
  char **p_aliases;
  int p_proto;
};

extern int h_errno;

/* h_errno error code */
#define HOST_NOT_FOUND    1
#define NO_RECOVERY       2
#define TRY_AGAIN         3
#define NO_DATA           4

struct hostent *gethostbyname(const char *);
struct hostent *gethostbyaddr(const void *, socklen_t, int);
struct netent *getnetbyname(const char *);
struct netent *getnetbyaddr(unsigned long, int);
struct servent *getservbyname(const char *, const char *);
struct servent *getservbyport(int, const char *);
struct protoent *getprotobyname(const char *);
struct protoent *getprotobynumber(int);

__END_DECLS

#endif /* _NETDB_H_ */
