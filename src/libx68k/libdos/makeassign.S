| int _dos_makeassign (const char *, const char *, int);
.text
.even
.global _dos_makeassign
.type _dos_makeassign,@function
_dos_makeassign:
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	move.l	%sp@(10), %sp@-
	move.w	#1, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff8f
	bras	3f
2:
	.short	0xff5f
3:
	lea	%sp@(12), %sp
	rts
