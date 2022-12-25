| int _dos_ioctrlrh (int, char *, int);
.text
.even
.global _dos_ioctrlrh
.type _dos_ioctrlrh,@function
_dos_ioctrlrh:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	move.w	#2, %sp@-
	.short	0xff44
	lea	%sp@(12), %sp
	rts
