| int _dos_c_down (int);
.text
.even
.global _dos_c_down
.type _dos_c_down,@function
_dos_c_down:
	move.w	%sp@(6), %sp@-
	move.w	#7, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
