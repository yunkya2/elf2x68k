| int _dos_c_putc (int);
.text
.even
.global _dos_c_putc
.type _dos_c_putc,@function
_dos_c_putc:
	move.w	%sp@(6), %sp@-
	clr.w	%sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
