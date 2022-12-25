| int _dos_c_print (const char *);
.text
.even
.global _dos_c_print
.type _dos_c_print,@function
_dos_c_print:
	move.l	%sp@(4), %sp@-
	move.w	#1, %sp@-
	.short	0xff23
	addq.l	#6, %sp
	rts
