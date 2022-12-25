| int _dos_ioctrlwd (int, const char *, int);
.text
.even
.global _dos_ioctrlwd
.type _dos_ioctrlwd,@function
_dos_ioctrlwd:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	move.w	#5, %sp@-
	.short	0xff44
	lea	%sp@(12), %sp
	rts
