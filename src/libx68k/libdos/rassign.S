| int _dos_rassign (const char *);
.text
.even
.global _dos_rassign
.type _dos_rassign,@function
_dos_rassign:
	move.l	%sp@(4), %sp@-
	move.w	#4, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff8f
	bras	3f
2:
	.short	0xff5f
3:
	addq.l	#6, %sp
	rts
