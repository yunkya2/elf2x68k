| int _dos_getassign (const char *, char *);
.text
.even
.global _dos_getassign
.type _dos_getassign,@function
_dos_getassign:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	clr.w	%sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff8f
	bras	3f
2:
	.short	0xff5f
3:
	lea	%sp@(10), %sp
	rts
