#ifndef _SYS_SOCKET_H_
#define _SYS_SOCKET_H_

#include <sys/cdefs.h>
#include <sys/types.h>
#include <sys/socket.h>

__BEGIN_DECLS

typedef size_t socklen_t;

struct sockaddr
{
  short sa_family;
  char sa_data[14];
};

struct sockaddr_storage
{
  short ss_family;
  char __ss_padding[128 - 2];
};

#define PF_LOCAL        1
#define PF_UNIX         PF_LOCAL
#define PF_INET         0

#define AF_LOCAL        PF_LOCAL
#define AF_UNIX         PF_UNIX
#define AF_INET         PF_INET

#define SOCK_STREAM     0
#define SOCK_DGRAM      1
#define SOCK_RAW        2

/* for shutdown(2) */
#define SHUT_RD         0
#define SHUT_WR         1
#define SHUT_RDWR       2

/* for setsockopt(2) */
#define SOL_SOCKET      1

/* inetd.x specific functions */
#define SO_GETVERSION   100   /* _get_version() */
#define SO_SOCKMODE     101   /* sockmode(fd, mode) */
#define SO_SOCKLENRECV  102   /* socklen(fd, 0) */
#define SO_SOCKLENSEND  103   /* socklen(fd, 1) */
#define SO_SOCKKICK     104   /* sockick(fd) */
#define SO_SOCKFLUSH    105   /* usflush(fd) */
#define SO_SOCKERR      106   /* sockerr(fd) */
#define SO_SOCKSTATE    107   /* sockstate(fd) */

/* for SO_SOCKMODE */
#define	SOCK_BINARY     0
#define	SOCK_ASCII      1
#define	SOCK_QUERY      2

int accept(int, struct sockaddr *, socklen_t *);
int bind(int, const struct sockaddr *, socklen_t);
int connect(int, const struct sockaddr *, socklen_t);
int listen(int, int);
int socket(int, int, int);
int getsockname(int, struct sockaddr *, socklen_t *);
int getpeername(int, struct sockaddr *, socklen_t *);
int shutdown(int, int);
ssize_t recv(int, void *, size_t, int);
ssize_t recvfrom(int, void *, size_t, int, struct sockaddr *, socklen_t *);
ssize_t send(int, const void *, size_t, int);
ssize_t sendto(int, const void *, size_t, int, const struct sockaddr *, socklen_t);
int getsockopt(int, int, int, void *, socklen_t *);
int setsockopt(int, int, int, const void *, socklen_t);

__END_DECLS

#endif /* _SYS_SOCKET_H_ */
