/*
 * Start entry point by Human68K XFile.
 *
 * Communication between the kernel and program is done
 * by setting cpu registers as is :
 * a0 : MCB pointer
 * a1 : End of bss segment
 * a2 : Command line pointer
 * a3 : Environ variable pointer
 * a4 : Execution entry point address
 * a5 : Interrupt routine command number (driver only)
 *
 * Preprocessor variable used by this file :
 * HUPAIR : Support hupair argument vector
 * RFILE : Support for .r Relocatable file loading
 */

#include "config.h"

.extern __crt1_startup
.extern _exit
.extern _stack_size
.extern _heap_size

.global _start

_start:
	bra	_start_1
#ifdef SUPPORT_HUPAIR
	.string "#HUPAIR"
#endif
	.string	"X68000 LIBC"
	.string "crt0-"
#ifdef SUPPORT_HUPAIR
	.string "h"
#endif
	.string "x"

	.even

.global __cxx_x68k_odd_relocation
__cxx_x68k_odd_relocation:
	.long	0

_start_1:
	move.l	%pc@(__cxx_x68k_odd_relocation), %d0
	beq.s	_start_2

	lea.l	%a0@(0x100), %a4	| Program base address
	movea.l	%d0, %a5
	adda.l	%a4, %a5
	move.l	%a4, %d1
	move.l	%a5, %a0@(0x30)		| fix BSS start address
	move.l	%a5, %a0@(0x34)		| fix heap start address

	moveq.l	#0, %d0
odd_relocate:
	move.w	%a5@+, %d0		| odd relocation info
	beq.s	_start_2
	cmpi.w	#0x0001, %d0
	bne.s	odd_relocate_1
	move.l	%a5@+, %d0
odd_relocate_1:
	adda.l	%d0, %a4		| get next fixup address
	move.b	%a4@, %d0
	lsl.l	#8, %d0
	move.b	%a4@(1), %d0
	lsl.l	#8, %d0
	move.b	%a4@(2), %d0
	lsl.l	#8, %d0
	move.b	%a4@(3), %d0
	add.l	%d1, %d0		| add base address
	move.b	%d0, %a4@(3)
	lsr.l	#8, %d0
	move.b	%d0, %a4@(2)
	lsr.l	#8, %d0
	move.b	%d0, %a4@(1)
	lsr.l	#8, %d0
	move.b	%d0, %a4@
	bra.s	odd_relocate

_start_2:
	move.l	%a0@(0x30), %a5

clear_bss:
	clr.l	%a5@+
	cmpa.l	%a5, %a1		| BSS End
	bgt.s	clear_bss

| Save crt0 arguments
	move.l	%a0, _MCB		| MCB
	lea.l	%a0@(0x100), %a5
	move.l	%a5, _PSTA		| TEXT Start
	move.l	%a0@(0x30), %d0
	move.l	%d0, _PEND		| TEXT End
	move.l	%d0, _BSTA		| BSS Start
	move.l	%a1, _BEND		| BSS End

	lea.l	%a0@(0x10), %a5
	move.l	%a5, _PSP

| Setup environment
	move.l	%a3, _ENV0

| Setup command line
	move.l	%a2, _cmdline

| Setup stack
	move.l	%a1, _SSTA
	add.l	_stack_size, %a1
	move.l	%a1, _SEND

| Setup heap
	move.l	%a1, _HSTA		| HEAP Start
	add.l	_heap_size, %a1
	move.l	%a1, _HEND		| HEAP End
	move.l	%a0@(0x08), _HMAX	| End block

	lea.l	%a0@(0x10), %a5		| PSP

	sub.l	%a5, %a1
	move.l	%a1, %sp@-		| incr
	move.l	%a5, %sp@-		| ptr
	.short	0xFF4A			| setblock
	addq.l	#8, %sp
	tst.l	%d0
	bmi	out_of_memory

	move.l	_SEND, %sp
	jmp	__crt1_startup		| Human initialization

out_of_memory:
	pea.l	%pc@(oom_msg)
	.short	0xff09			| print
	addq.l	#4, %sp
	move.w	#0x007f, %sp@-
	.short	0xff4c			| exit2

	|
	| No return
	|

oom_msg:
	.ascii	"Out of memory. Program terminated."
	.byte	13,10,0
	.even

|
| Variables
|

	.comm	_MCB, 4
	.comm	_PSP, 4

	.comm	_PSTA, 4
	.comm	_PEND, 4
	.comm	_BSTA, 4
	.comm	_BEND, 4
	.comm	_SSTA, 4
	.comm	_SEND, 4
	.comm	_HSTA, 4
	.comm	_HEND, 4
	.comm	_HMAX, 4

	.comm	_ENV0, 4

	.comm	_cmdline, 4

