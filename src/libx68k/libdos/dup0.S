| int _dos_dup0 (int, int);
.text
.even
.global _dos_dup0
.type _dos_dup0,@function
_dos_dup0:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	.short	0xff2f
	addq.l	#4, %sp
	rts
