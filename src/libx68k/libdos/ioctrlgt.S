| int _dos_ioctrlgt (int);
.text
.even
.global _dos_ioctrlgt
.type _dos_ioctrlgt,@function
_dos_ioctrlgt:
	move.w	%sp@(6), %sp@-
	clr.w	%sp@-
	.short	0xff44
	addq.l	#4, %sp
	rts
