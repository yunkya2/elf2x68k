| int _dos_c_fnkmod (int);
.text
.even
.global _dos_c_fnkmod
.type _dos_c_fnkmod,@function
_dos_c_fnkmod:
	move.w	%sp@(6), %sp@-
	move.w	#14, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
