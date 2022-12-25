| int _dos_move (const char *, const char *);
.text
.even
.global _dos_move
.type _dos_move,@function
_dos_move:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff86
	bras	3f
2:
	.short	0xff56
3:
	addq.l	#8, %sp
	rts
