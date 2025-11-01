| void *_dos_malloc2 (int, int);
.text
.even
.global _dos_malloc2
.type _dos_malloc2,@function
_dos_malloc2:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff88
	addq.l	#6, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
