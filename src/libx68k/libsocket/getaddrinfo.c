/*
 *  getaddrinfo()
 */

#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>

int getaddrinfo(const char *node, const char *service,
                 const struct addrinfo *hints,
                 struct addrinfo **res)
{
    struct hostent *he;
    struct sockaddr_in *addr;
    struct addrinfo *ai;
    int port = 0;

    if (!node && !service) {
        return EAI_NONAME;
    }

    if (service) {
        port = atoi(service);
    }

    he = gethostbyname(node);
    if (!he) {
        return EAI_FAIL;
    }

    ai = (struct addrinfo *)malloc(sizeof(struct addrinfo));
    if (!ai) {
        return EAI_MEMORY;
    }
    addr = (struct sockaddr_in *)malloc(sizeof(struct sockaddr_in));
    if (!addr) {
        free(ai);
        return EAI_MEMORY;
    }

    ai->ai_flags = hints ? hints->ai_flags : 0;
    ai->ai_family = AF_INET;
    ai->ai_socktype = hints ? hints->ai_socktype : SOCK_STREAM;
    ai->ai_protocol = hints ? hints->ai_protocol : 0;
    ai->ai_addrlen = sizeof(struct sockaddr_in);
    ai->ai_addr = (struct sockaddr *)addr;
    ai->ai_canonname = NULL;
    ai->ai_next = NULL;

    addr->sin_family = AF_INET;
    addr->sin_port = htons(port);
    memcpy(&addr->sin_addr, he->h_addr, sizeof(addr->sin_addr));

    *res = ai;
    return 0;
}
void freeaddrinfo(struct addrinfo *res)
{
    if (res) {
        if (res->ai_addr) {
            free(res->ai_addr);
        }
        if (res->ai_canonname) {
            free(res->ai_canonname);
        }
        free(res);
    }
}
