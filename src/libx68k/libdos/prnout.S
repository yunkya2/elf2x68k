| void _dos_prnout (int);
.text
.even
.global _dos_prnout
.type _dos_prnout,@function
_dos_prnout:
	move.w	%sp@(6), %sp@-
	.short	0xff05
	addq.l	#2, %sp
	rts
