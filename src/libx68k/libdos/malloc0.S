| void *_dos_malloc0 (int, int, int);
.text
.even
.global _dos_malloc0
.type _dos_malloc0,@function
_dos_malloc0:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %d0
	or.w	#0x8000, %d0
	move.w	%d0, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff88
	bras	3f
2:
	.short	0xff58
3:
	lea	%sp@(10), %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
