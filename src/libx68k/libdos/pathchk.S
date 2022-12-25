| int _dos_pathchk (const char *, const struct _dos_comline *, const char *);
.text
.even
.global _dos_comline
.type _dos_comline,@function
_dos_comline:
	movem.l	%sp@(4), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	move.w	#2, %sp@-
	.short	0xff4b
	lea	%sp@(14), %sp
	rts
