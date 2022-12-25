| long _dos_seek (int, int, int);
.text
.even
.global _dos_seek
.type _dos_seek,@function
_dos_seek:
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	move.w	%sp@(12), %sp@-
	.short	0xff42
	addq.l	#8, %sp
	rts
