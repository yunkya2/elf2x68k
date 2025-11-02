/*
 *  pthread_attr_init()
 *  pthread_attr_destroy()
 */

#include "pthread_internal.h"

int	pthread_attr_init(pthread_attr_t *attr)
{
    attr->is_initialized = 1;	
	attr->stackaddr = NULL;
	attr->stacksize = PTH_DEFAULT_USERSTACKSIZE;
	attr->systemstackaddr = NULL;
	attr->systemstacksize = PTH_DEFAULT_SYSTEMSTACKSIZE;
	attr->detachstate = PTHREAD_CREATE_JOINABLE;
	attr->priority = PTH_DEFAULT_PRIORITY;
	attr->name[0] = '\0';
	return 0;
}

int	pthread_attr_destroy(pthread_attr_t *attr)
{
    attr->is_initialized = 0;	
    return 0;
}
