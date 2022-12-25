| struct _dos_psp *_dos_setpdb (struct _dos_psp *);
.text
.even
.global _dos_psp
.type _dos_psp,@function
_dos_psp:
	move.l	%sp@(4), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff80
	bras	3f
2:
	.short	0xff50
3:
	addq.l	#4, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
