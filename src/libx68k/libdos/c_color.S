| int _dos_c_color (int);
.text
.even
.global _dos_c_color
.type _dos_c_color,@function
_dos_c_color:
	move.w	%sp@(6), %sp@-
	move.w	#2, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
