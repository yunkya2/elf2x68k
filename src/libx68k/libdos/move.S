| int _dos_move (const char *, const char *);
.text
.even
.global _dos_move
.type _dos_move,@function
_dos_move:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff86
	addq.l	#8, %sp
	rts
