| int _dos_filedate (int, int);
.text
.even
.global _dos_filedate
.type _dos_filedate,@function
_dos_filedate:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff87
	addq.l	#6, %sp
	rts
