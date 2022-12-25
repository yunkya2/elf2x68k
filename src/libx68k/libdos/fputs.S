| void _dos_fputs (const char *, int);
.text
.even
.global _dos_fputs
.type _dos_fputs,@function
_dos_fputs:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff1e
	addq.l	#6, %sp
	rts
