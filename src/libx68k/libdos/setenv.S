| int _dos_setenv (const char *, const char *, const char *);
.text
.even
.global _dos_setenv
.type _dos_setenv,@function
_dos_setenv:
	movem.l	%sp@(4), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff82
	bras	3f
2:
	.short	0xff52
3:
	lea	%sp@(12), %sp
	rts
