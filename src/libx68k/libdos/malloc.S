| void *_dos_malloc (int);
.text
.even
.global _dos_malloc
.type _dos_malloc,@function
_dos_malloc:
	move.l	%sp@(4), %sp@-
	.short	0xff48
	addq.l	#4, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
