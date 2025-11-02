/*
 *  pthread_attr_setname_np()
 */

#include <string.h>
#include "pthread_internal.h"

int	pthread_attr_setname_np(pthread_attr_t *attr, const char *name)
{
    if (!attr || !attr->is_initialized) {
        return EINVAL;
    }

    strncpy(attr->name, name, sizeof(attr->name) - 1);
    attr->name[sizeof(attr->name) - 1] = '\0';

    return 0;
}
