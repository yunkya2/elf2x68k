| int _dos_setenv (const char *, const char *, const char *);
.text
.even
.global _dos_setenv
.type _dos_setenv,@function
_dos_setenv:
	movem.l	%sp@(4), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	.short	0xff82
	lea	%sp@(12), %sp
	rts
