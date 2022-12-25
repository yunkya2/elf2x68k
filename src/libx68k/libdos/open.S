| int _dos_open (const char *, int);
.text
.even
.global _dos_open
.type _dos_open,@function
_dos_open:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff3d
	addq.l	#6, %sp
	rts
