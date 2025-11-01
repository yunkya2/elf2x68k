| int _dos_maketmp (const char *, int);
.text
.even
.global _dos_maketmp
.type _dos_maketmp,@function
_dos_maketmp:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff8a
	addq.l	#6, %sp
	rts
