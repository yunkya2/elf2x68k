| int _dos_getenv (const char *, const char *, char *);
.text
.even
.global _dos_getenv
.type _dos_getenv,@function
_dos_getenv:
	movem.l	%sp@(4), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff83
	bras	3f
2:
	.short	0xff53
3:
	lea	%sp@(12), %sp
	rts
