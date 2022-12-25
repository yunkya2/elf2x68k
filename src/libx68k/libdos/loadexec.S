| int _dos_loadexec (const char *, const struct _dos_comline *, const char *);
.text
.even
.global _dos_comline
.type _dos_comline,@function
_dos_comline:
	movem.l	%d2-%d7/%a2-%a6, %sp@-
	movem.l	%sp@(48), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	clr.w	%sp@-
	.short	0xff4b
	lea	%sp@(14), %sp
	movem.l	%sp@+, %d2-%d7/%a2-%a6
	rts
