| int _dos_ioctrlst (int, int);
.text
.even
.global _dos_ioctrlst
.type _dos_ioctrlst,@function
_dos_ioctrlst:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	move.w	#1, %sp@-
	.short	0xff44
	addq.l	#6, %sp
	rts
