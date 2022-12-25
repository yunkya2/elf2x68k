| void _dos_fputc (int, int);
.text
.even
.global _dos_fputc
.type _dos_fputc,@function
_dos_fputc:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	.short	0xff1d
	addq.l	#4, %sp
	rts
