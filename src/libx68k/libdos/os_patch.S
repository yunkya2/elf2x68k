| void *_dos_os_patch (unsigned int, void *);
.text
.even
.global _dos_os_patch
.type _dos_os_patch,@function
_dos_os_patch:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xffab
	addq.l	#6, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
