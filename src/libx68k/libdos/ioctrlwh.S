| int _dos_ioctrlwh (int, const char *, int);
.text
.even
.global _dos_ioctrlwh
.type _dos_ioctrlwh,@function
_dos_ioctrlwh:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	move.w	#3, %sp@-
	.short	0xff44
	lea	%sp@(12), %sp
	rts
