/*
 *  pthread_cleanup_push()
 *  pthread_cleanup_pop()
 */

#include "pthread_internal.h"

void _pthread_cleanup_push(struct _pthread_cleanup_context *context, void (*routine)(void *), void *arg)
{
    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return;     // Current thread not found
    }

    struct _pthread_cleanup_context *current = malloc(sizeof(struct _pthread_cleanup_context));
    if (current == NULL) {
        return;     // Memory allocation failed
    }
    current->_routine = routine;
    current->_arg = arg;
    current->_previous = pi->cleanup;
    pi->cleanup = current;  // クリーンアップコンテキストをスタックに追加
}

void _pthread_cleanup_pop(struct _pthread_cleanup_context *context, int execute)
{
    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return;     // Current thread not found
    }

    if (pi->cleanup) {
        struct _pthread_cleanup_context *current = pi->cleanup;
        pi->cleanup = current->_previous;
        if (execute) {
            current->_routine(current->_arg);
        }
        free(current);  // クリーンアップコンテキストを解放
    }
}

void __pthread_call_all_cleanup(pthread_internal_t *pi)
{
    if (pi == NULL) {
        return;
    }

    while (pi->cleanup) {
        struct _pthread_cleanup_context *current = pi->cleanup;
        pi->cleanup = current->_previous;
        current->_routine(current->_arg);
        free(current);  // クリーンアップコンテキストを解放
    }
}
