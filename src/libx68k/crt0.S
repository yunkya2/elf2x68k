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

#ifdef SUPPORT_HUPAIR
	.extern __crt1_startup_hupair
#else
	.extern __crt1_startup
#endif
	.extern _exit
	.extern _stack_size
	.extern _heap_size

	.extern _MCB
	.extern _PSP
	.extern _PSTA
	.extern _PEND
	.extern _BSTA
	.extern _BEND
	.extern _SSTA
	.extern _SEND
	.extern _HSTA
	.extern _HEND
	.extern _HMAX
	.extern _ENV0
	.extern _cmdline

	.extern	_mpu_type
	.extern	_fpu_type

	.global _start
_start:
	bra.s	_start_1
#ifdef SUPPORT_HUPAIR
	.string "#HUPAIR"
#endif
	.string	"#NEWLIB"

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

odd_relocate:
	moveq.l	#0, %d0
	move.w	%a5@+, %d0		| odd relocation info
	beq.s	_start_2
	cmpi.w	#0x0001, %d0
	bne.s	odd_relocate_1
	move.l	%a5@+, %d0
odd_relocate_1:
	lea.l	%a4@(4,%d0:l), %a4	| get next fixup address

	add.b	%d1, %a4@-
	ror.l	#8, %d1

	move.b	%a4@-, %d0
	addx.b	%d1, %d0
	move.b	%d0, %a4@
	ror.l	#8, %d1

	move.b	%a4@-, %d0
	addx.b	%d1, %d0
	move.b	%d0, %a4@
	ror.l	#8, %d1

	move.b	%a4@-, %d0
	addx.b	%d1, %d0
	move.b	%d0, %a4@
	ror.l	#8, %d1

	bra.s	odd_relocate

_start_2:
	move.l	%a0@(0x30), %a5

clear_bss:
	clr.l	%a5@+
	cmpa.l	%a5, %a1		| BSS End
	bgt.s	clear_bss

| Save crt0 arguments
	lea.l	_MCB, %a5
	move.l	%a0, %a5@+		| _MCB
	lea.l	%a0@(0x100), %a4
	move.l	%a4, %a5@+		| _PSTA (TEXT Start)
	move.l	%a0@(0x30), %d0
	move.l	%d0, %a5@+		| _PEND (TEXT End)
	move.l	%d0, %a5@+		| _BSTA (BSS Start)
	move.l	%a1, %a5@+		| _BEND (BSS End)

| Setup environment
	move.l	%a3, %a5@+		| _ENV0

| Setup command line
	move.l	%a2, %a5@+		| _cmdline

	lea.l	_SSTA, %a5
	tst.l	%a5@			| _SSTA (STACK Start)
	bne.s	1f

| Setup stack
	move.l	%a1, %a5@		| _SSTA (STACK Start)
	add.l	_stack_size, %a1
	move.l	%a1, _SEND		| _SEND (STACK End)
1:

	lea.l	_HSTA, %a5
	tst.l	%a5@			| _HSTA (HEAP Start)
	bne.s	1f

| Setup heap
	move.l	%a1, %a5@		| _HSTA (HEAP Start)
	add.l	_heap_size, %a1
	move.l	%a1, _HEND		| _HEND (HEAP End)
	move.l	%a0@(0x08), _HMAX	| _HMAX (HEAP End Max)

1:
	lea.l	%a0@(0x10), %a5
	move.l	%a5, _PSP		| _PSP

| Shrink memory block
	sub.l	%a5, %a1
	move.l	%a1, %sp@-		| len
	move.l	%a5, %sp@-		| memptr
	.short	0xFF4A			| DOS _SETBLOCK
	addq.l	#8, %sp
	tst.l	%d0
	bmi.s	out_of_memory

	moveq.l	#_mpu_type, %d2
	beq.s	_start_3		| no MPU type support

	lea.l	0xcbc.w, %a1
	moveq.l	#0xffffff82, %d0	| IOCS _B_PEEK
	trap	#15			| get MPU type
	btst.l	%d0, %d2
	beq.s	mpu_mismatch

	moveq.l	#_fpu_type, %d2
	beq.s	_start_3		| FPU is not needed

	moveq.l	#0xffffff82, %d0	| IOCS _B_PEEK
	trap	#15			| get FPU flag
	tst.b	%d0
	beq.s	mpu_mismatch

_start_3:
	move.l	_SEND, %sp
#ifdef SUPPORT_HUPAIR
	jmp	__crt1_startup_hupair	| Human initialization
#else
	jmp	__crt1_startup		| Human initialization
#endif

out_of_memory:
	pea.l	%pc@(oom_msg)
	bra.s	1f
mpu_mismatch:
	pea.l	%pc@(mmm_msg)
1:
	.short	0xff09			| DOS _PRINT
program_terminated:
	pea.l	%pc@(term_msg)
	.short	0xff09			| DOS _PRINT
	move.w	#0x007f, %sp@-
	.short	0xff4c			| DOS _EXIT2

	|
	| No return
	|

oom_msg:
	.asciz	"Out of memory."
mmm_msg:
	.asciz	"MPU/FPU mismatch."
term_msg:
	.ascii	" Program terminated."
	.byte	13,10,0
	.even
