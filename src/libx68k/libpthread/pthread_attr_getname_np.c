/*
 *  pthread_attr_getname_np()
 */

#include <string.h>
#include "pthread_internal.h"

int	pthread_attr_getname_np(const pthread_attr_t *attr, char *name, size_t len)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    strncpy(name, attr->name, len - 1);
    name[len - 1] = '\0';

    return 0;
}
