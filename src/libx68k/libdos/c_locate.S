| int _dos_c_locate (int, int);
.text
.even
.global _dos_c_locate
.type _dos_c_locate,@function
_dos_c_locate:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	move.w	#3, %sp@-
	.short	0xff23
	addq.l	#6, %sp
	rts
