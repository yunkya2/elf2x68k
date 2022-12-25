| int _dos_c_del (int);
.text
.even
.global _dos_c_del
.type _dos_c_del,@function
_dos_c_del:
	move.w	%sp@(6), %sp@-
	move.w	#13, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
