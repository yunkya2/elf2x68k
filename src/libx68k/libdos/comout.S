| void _dos_comout (int);
.text
.even
.global _dos_comout
.type _dos_comout,@function
_dos_comout:
	move.w	%sp@(6), %sp@-
	.short	0xff04
	addq.l	#2, %sp
	rts
