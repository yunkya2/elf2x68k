| struct _dos_psp *_dos_setpdb (struct _dos_psp *);
.text
.even
.global _dos_setpdb
.type _dos_setpdb,@function
_dos_setpdb:
	move.l	%sp@(4), %sp@-
	.short	0xff80
	addq.l	#4, %sp
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
