| int _dos_curdir (int, char *);
.text
.even
.global _dos_curdir
.type _dos_curdir,@function
_dos_curdir:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff47
	addq.l	#6, %sp
	rts
