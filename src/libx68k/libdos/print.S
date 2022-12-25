| void _dos_print (const char *);
.text
.even
.global _dos_print
.type _dos_print,@function
_dos_print:
	move.l	%sp@(4), %sp@-
	.short	0xff09
	addq.l	#4, %sp
	rts
