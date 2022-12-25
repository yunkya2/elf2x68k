| int _dos_dup (int);
.text
.even
.global _dos_dup
.type _dos_dup,@function
_dos_dup:
	move.w	%sp@(6), %sp@-
	.short	0xff45
	addq.l	#2, %sp
	rts
