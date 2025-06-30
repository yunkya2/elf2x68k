/*
 * system cleanup handler APIs
 */

#include <stdlib.h>
#include <x68k/dos.h>
#include "_at_exit.h"

static void (*exit_funcs[AT_EXIT_MAX])(int) = { NULL };

int __at_exit(void (*func)(int))
{
    for (int i = 0; i < AT_EXIT_MAX; i++) {
        if (exit_funcs[i] == NULL) {
        exit_funcs[i] = func;
        return 0;
        }
    }
    return -1;
}

void __at_exit_call(int type)
{
    for (int i = AT_EXIT_MAX - 1; i >= 0; i--) {
        if (exit_funcs[i] != NULL) {
            exit_funcs[i](type);
            exit_funcs[i] = NULL;
        }
    }
}

static void (*prev_exitvc)(void) = NULL;
static void (*prev_ctrlvc)(void) = NULL;
static void (*prev_errjvc)(void) = NULL;

#define call_at_exit(type, prev)    \
    __asm__ volatile(                               \
        "movem.l %%d0-%%d2/%%a0-%%a2,%%sp@-\n"      \
        "move.l  %0,%%sp@-\n"                       \
        "bsr     __at_exit_call\n"                  \
        "addq.l  #4,%%sp\n"                         \
        "movem.l %%sp@+,%%d0-%%d2/%%a0-%%a2\n"      \
        "move.l  %1,%%sp@-\n"                       \
        : : "i"(type), "m"(prev)                    \
    );

static void __at_exit_call_exitvc(void)
{
    call_at_exit(AT_EXIT_TYPE_EXITVC, prev_exitvc);
}

static void __at_exit_call_ctrlvc(void)
{
    call_at_exit(AT_EXIT_TYPE_CTRLVC, prev_ctrlvc);
}

static void __at_exit_call_errjvc(void)
{
    call_at_exit(AT_EXIT_TYPE_ERRJVC, prev_errjvc);
}

void __at_exit_init(void)
{
    prev_exitvc = _dos_intvcs(0xfff0, __at_exit_call_exitvc);
    prev_ctrlvc = _dos_intvcs(0xfff1, __at_exit_call_ctrlvc);
    prev_errjvc = _dos_intvcs(0xfff2, __at_exit_call_errjvc);
}
