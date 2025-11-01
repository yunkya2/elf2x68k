| union _dos_fcb *_dos_get_fcb_adr (unsigned int);
.text
.even
.global _dos_get_fcb_adr
.type _dos_get_fcb_adr,@function
_dos_get_fcb_adr:
	move.w	%sp@(6), %sp@-
	.short	0xffac
	addq.l	#2, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
