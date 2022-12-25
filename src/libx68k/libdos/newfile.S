| int _dos_newfile (const char *, _dos_mode_t);
.text
.even
.global _dos_newfile
.type _dos_newfile,@function
_dos_newfile:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff8b
	bras	3f
2:
	.short	0xff5b
3:
	addq.l	#6, %sp
	rts
