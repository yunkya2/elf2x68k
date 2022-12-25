| union _dos_fcb *_dos_get_fcb_adr (unsigned int);
.text
.even
.global _dos_get_fcb_adr
.type _dos_get_fcb_adr,@function
_dos_get_fcb_adr:
	move.w	%sp@(6), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xffac
	bras	3f
2:
	.short	0xff7c
3:
	addq.l	#2, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
