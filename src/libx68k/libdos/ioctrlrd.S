| int _dos_ioctrlrd (int, char *, int);
.text
.even
.global _dos_ioctrlrd
.type _dos_ioctrlrd,@function
_dos_ioctrlrd:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	move.w	#4, %sp@-
	.short	0xff44
	lea	%sp@(12), %sp
	rts
