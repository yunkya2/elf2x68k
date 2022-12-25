| void _dos_pspset (struct _dos_psp *);
.text
.even
.global _dos_psp
.type _dos_psp,@function
_dos_psp:
	move.l	%sp@(4), %sp@-
	.short	0xff26
	addq.l	#4, %sp
	rts
