| int _dos_maketmp (const char *, int);
.text
.even
.global _dos_maketmp
.type _dos_maketmp,@function
_dos_maketmp:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff8a
	bras	3f
2:
	.short	0xff5a
3:
	addq.l	#6, %sp
	rts
