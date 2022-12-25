| void *_dos_intvcs (int, void *);
.text
.even
.global _dos_intvcs
.type _dos_intvcs,@function
_dos_intvcs:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff25
	addq.l	#6, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
