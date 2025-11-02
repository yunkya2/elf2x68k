TARGET = libpthread.a

include ../Common.mk

CFLAGS += -I.. -Iinclude -g

LIB_SOURCES = \
	pthread.c \
	pthread_self.c \
	pthread_detach.c \
	pthread_cancel.c \
	pthread_testcancel.c \
	pthread_setcancelstate.c \
	pthread_setcanceltype.c \
	pthread_equal.c \
	pthread_yield.c \
	pthread_once.c \
	pthread_cleanup.c \
	pthread_attr_init.c \
	pthread_attr_setstack.c \
	pthread_attr_getstack.c \
	pthread_attr_setstacksize.c \
	pthread_attr_getstacksize.c \
	pthread_attr_setsystemstack_np.c \
	pthread_attr_getsystemstack_np.c \
	pthread_attr_setsystemstacksize_np.c \
	pthread_attr_getsystemstacksize_np.c \
	pthread_attr_setdetachstate.c \
	pthread_attr_getdetachstate.c \
	pthread_attr_setschedparam.c \
	pthread_attr_getschedparam.c \
	pthread_attr_setname_np.c \
	pthread_attr_getname_np.c \
	pthread_key.c \
	pthread_mutex_init.c \
	pthread_mutex_destroy.c \
	pthread_mutex_lock.c \
	pthread_mutex_trylock.c \
	pthread_mutex_unlock.c \
	pthread_mutexattr_init.c \
	pthread_cond_init.c \
	pthread_cond_destroy.c \
	pthread_cond_signal.c \
	pthread_cond_broadcast.c \
	pthread_cond_wait.c \
	pthread_condattr_init.c \
	pthread_barrier_init.c \
	pthread_barrier_destroy.c \
	pthread_barrier_wait.c \
	pthread_barrierattr_init.c \
	pthread_spin_init.c \
	pthread_spin_destroy.c \
	pthread_spin_lock.c \
	pthread_spin_trylock.c \
	pthread_spin_unlock.c \
	pthread_rwlock_init.c \
	pthread_rwlock_destroy.c \
	pthread_rwlock_rdlock.c \
	pthread_rwlock_tryrdlock.c \
	pthread_rwlock_wrlock.c \
	pthread_rwlock_trywrlock.c \
	pthread_rwlock_unlock.c \
	pthread_rwlockattr_init.c \

OBJ = $(LIB_SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJ)
	$(AR) $(ARFLAGS) $@ $^
	$(RANLIB) $@

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o $(TARGET)

.PHONY: all clean
