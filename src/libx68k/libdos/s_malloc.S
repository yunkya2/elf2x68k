| void *_dos_s_malloc (int, int);
.text
.even
.global _dos_s_malloc
.type _dos_s_malloc,@function
_dos_s_malloc:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xffad
	bras	3f
2:
	.short	0xff7d
3:
	addq.l	#6, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
