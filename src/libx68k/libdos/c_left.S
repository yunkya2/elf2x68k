| int _dos_c_left (int);
.text
.even
.global _dos_c_left
.type _dos_c_left,@function
_dos_c_left:
	move.w	%sp@(6), %sp@-
	move.w	#9, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
