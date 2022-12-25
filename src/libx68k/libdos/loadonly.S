| int _dos_loadonly (const char *, const void *, const void *);
.text
.even
.global _dos_loadonly
.type _dos_loadonly,@function
_dos_loadonly:
	movem.l	%sp@(4), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	move.w	#3, %sp@-
	.short	0xff4b
	lea	%sp@(14), %sp
	rts
