| int _dos_c_width (int);
.text
.even
.global _dos_c_width
.type _dos_c_width,@function
_dos_c_width:
	move.w	%sp@(6), %sp@-
	move.w	#16, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
