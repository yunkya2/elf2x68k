| void *_dos_os_patch (unsigned int, void *);
.text
.even
.global _dos_os_patch
.type _dos_os_patch,@function
_dos_os_patch:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xffab
	bras	3f
2:
	.short	0xff7b
3:
	addq.l	#6, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
