| void _dos_pspset (struct _dos_psp *);
.text
.even
.global _dos_pspset
.type _dos_pspset,@function
_dos_pspset:
	move.l	%sp@(4), %sp@-
	.short	0xff26
	addq.l	#4, %sp
	rts
