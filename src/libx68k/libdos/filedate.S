| int _dos_filedate (int, int);
.text
.even
.global _dos_filedate
.type _dos_filedate,@function
_dos_filedate:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff87
	bras	3f
2:
	.short	0xff57
3:
	addq.l	#6, %sp
	rts
