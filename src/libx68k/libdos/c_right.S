| int _dos_c_right (int);
.text
.even
.global _dos_c_right
.type _dos_c_right,@function
_dos_c_right:
	move.w	%sp@(6), %sp@-
	move.w	#8, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
