| int _dos_c_up (int);
.text
.even
.global _dos_c_up
.type _dos_c_up,@function
_dos_c_up:
	move.w	%sp@(6), %sp@-
	move.w	#6, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
