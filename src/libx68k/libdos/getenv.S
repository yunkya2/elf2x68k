| int _dos_getenv (const char *, const char *, char *);
.text
.even
.global _dos_getenv
.type _dos_getenv,@function
_dos_getenv:
	movem.l	%sp@(4), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	.short	0xff83
	lea	%sp@(12), %sp
	rts
