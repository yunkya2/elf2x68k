| void _dos_putchar (int);
.text
.even
.global _dos_putchar
.type _dos_putchar,@function
_dos_putchar:
	move.w	%sp@(6), %sp@-
	.short	0xff02
	addq.l	#2, %sp
	rts
