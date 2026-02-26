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

extern int __sock_errno;            // SO_ERRORで返すエラーコード

char *__socket_sockstate(int sockfd);
int __socket_nonblock(int sockfd, int nonblock);

int __socket_accept_issaved(void);
int __socket_accept_save(int sockfd, int newfd, struct sockaddr *addr, socklen_t *addrlen);
int __socket_accept_internal(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

int __socket_connect_confirm(int sockfd);

int __socket_handle_recv_result(int sockfd);
int __socket_handle_send_result(int sockfd);

#endif /* _SOCKET_INTERNAL_H_ */
