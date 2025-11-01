| void *_dos_s_malloc (int, int);
.text
.even
.global _dos_s_malloc
.type _dos_s_malloc,@function
_dos_s_malloc:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xffad
	addq.l	#6, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
