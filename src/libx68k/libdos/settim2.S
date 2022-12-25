| int _dos_settim2 (int);
.text
.even
.global _dos_settim2
.type _dos_settim2,@function
_dos_settim2:
	move.l	%sp@(4), %sp@-
	.short	0xff28
	addq.l	#4, %sp
	rts
