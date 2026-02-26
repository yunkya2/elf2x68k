#ifndef _SOCKET_INTERNAL_H_
#define _SOCKET_INTERNAL_H_

#include <sys/types.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <x68k/dos.h>

#include "tcpipdrv.h"

extern uint32_t __sock_fds;         // 現在オープン中のsocketのビットマスク (fd=128～159に対応)
extern uint32_t __sock_connect_fds; // connect()中のsocketのビットマスク (fd=128～159に対応)
extern uint32_t __sock_listen_fds;  // listen()中のsocketのビットマスク (fd=128～159に対応)

char *__socket_sockstate(int sockfd);
int __socket_nonblock(int sockfd, int nonblock);

int __socket_push_accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

#endif /* _SOCKET_INTERNAL_H_ */
