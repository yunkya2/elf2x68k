/*
 * Start entry point (without Human68k).
 */

#include "config.h"

	.extern main
	.extern exit
	.extern	atexit
	.extern _stack_size
	.extern _heap_size

	.extern __bss_start
	.extern _end

	.extern _SSTA
	.extern _SEND
	.extern _HSTA
	.extern _HEND

	.global _start
_start:
	bra	_start_1

	.even

_start_1:
| Setup stack
	lea.l	_end, %a0
	move.l	%a0, _SSTA
	add.l	_stack_size, %a0
	move.l	%a0, _SEND

	move.l	%a0, %sp

| Setup heap
	move.l	%a0, _HSTA		| HEAP Start
	add.l	_heap_size, %a0
	move.l	%a0, _HEND		| HEAP End

| Clear bss section
	move.l	#__bss_start, %d1
	move.l	#_end, %d0
	cmp.l	%d0, %d1
	beq	3f
	move.l	%d1, %a0
	sub.l	%d1, %d0
	subq.l	#1, %d0
2:
	clr.b	%a0@+
	dbra	%d0, 2b
3:

	pea.l	__FINI_SECTION__
	jsr	atexit
	addq.l	#4, %sp

	jsr	__INIT_SECTION__

	pea.l	0
	pea.l	environ
	pea.l	%sp@(4)
	pea.l	0
	jsr	main
	lea.l	%sp@(16), %sp

	move.l	%d0, %sp@-
	jsr	exit

99:
	bra	99b

	|
	| No return
	|

|
| Empty environment
|
	.data
	.align	2
.global environ
environ:
	.long	0
