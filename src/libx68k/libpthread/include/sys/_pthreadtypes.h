#ifndef _SYS__PTHREADTYPES_H_
#define	_SYS__PTHREADTYPES_H_

#if defined(_POSIX_THREADS)

#include <sys/sched.h>

/* For thread APIs */

typedef uint32_t pthread_t;

struct pthread_internal;

#define PTHREAD_CREATE_DETACHED   0
#define PTHREAD_CREATE_JOINABLE   1

typedef struct {
  int is_initialized;
  void *stackaddr;
  int stacksize;
  void *systemstackaddr;
  int systemstacksize;
  int detachstate;
  int priority;
} pthread_attr_t;

int	pthread_attr_setsystemstack_np(pthread_attr_t *attr, void *stackaddr, size_t stacksize);
int	pthread_attr_getsystemstack_np(const pthread_attr_t *attr, void **stackaddr, size_t *stacksize);
int	pthread_attr_setsystemstacksize_np(pthread_attr_t *attr, size_t stacksize);
int	pthread_attr_getsystemstacksize_np(const pthread_attr_t *attr, size_t *stacksize);


/* For mutex APIs */

typedef struct pthread_mutex_t {
  int8_t is_initialized;
  volatile int8_t mutex;
  struct pthread_internal *waiting;
  struct pthread_internal **waiting_tail;
} pthread_mutex_t;

#define _PTHREAD_MUTEX_INITIALIZER  \
  ((pthread_mutex_t)  \
  { .is_initialized = 1, \
    .mutex = 0 \
  })

#define PTHREAD_MUTEX_NORMAL     0
#define PTHREAD_MUTEX_RECURSIVE  1
#define PTHREAD_MUTEX_ERRORCHECK 2
#define PTHREAD_MUTEX_DEFAULT    3

  typedef struct {
  int type;
} pthread_mutexattr_t;


/* For conditional variable APIs */

typedef struct pthread_cond_t {
  int8_t is_initialized;
  struct pthread_internal *waiting;
  struct pthread_internal **waiting_tail;
} pthread_cond_t;

#define _PTHREAD_COND_INITIALIZER  \
  ((pthread_cond_t)  \
  { .is_initialized = 1 \
  })

typedef struct {
} pthread_condattr_t;


/* For thread specific data APIs */

#define PTHREAD_KEYS_MAX      4

typedef uint32_t pthread_key_t;


/* For other thread APIs */

typedef struct {
  int   is_initialized;
  int   init_executed;
} pthread_once_t;

#endif /* defined(_POSIX_THREADS) */


/* POSIX Barrier APIs */

#if defined(_POSIX_BARRIERS)

typedef struct pthread_barrier_t {
  int8_t is_initialized;
  unsigned count;
  unsigned nwaiting;
  struct pthread_internal *waiting;
  struct pthread_internal **waiting_tail;
} pthread_barrier_t;

typedef struct {
} pthread_barrierattr_t;

#endif /* defined(_POSIX_BARRIERS) */


/* POSIX Spin Lock APIs */

#if defined(_POSIX_SPIN_LOCKS)

typedef struct pthread_spinlock_t {
  volatile int8_t lock;
} pthread_spinlock_t;

#define PTHREAD_PROCESS_PRIVATE 0
#define PTHREAD_PROCESS_SHARED  1

#endif /* defined(_POSIX_SPIN_LOCKS) */


/* POSIX Reader/Writer Lock APIs */

#if defined(_POSIX_READER_WRITER_LOCKS)

typedef struct pthread_rwlock_t {
  int8_t is_initialized;
  int count;
  struct pthread_internal *rd_waiting;
  struct pthread_internal **rd_waiting_tail;
  struct pthread_internal *wr_waiting;
  struct pthread_internal **wr_waiting_tail;
} pthread_rwlock_t;

#define _PTHREAD_RWLOCK_INITIALIZER  \
  ((pthread_rwlock_t)  \
  { .is_initialized = 1 \
  })

typedef struct {
} pthread_rwlockattr_t;

#endif /* defined(_POSIX_READER_WRITER_LOCKS) */

#endif /* ! _SYS__PTHREADTYPES_H_ */
