| void *_dos_intvcg (int);
.text
.even
.global _dos_intvcg
.type _dos_intvcg,@function
_dos_intvcg:
	move.w	%sp@(6), %sp@-
	.short	0xff35
	addq.l	#2, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
