| int _dos_bindno (const char *, const char *);
.text
.even
.global _dos_bindno
.type _dos_bindno,@function
_dos_bindno:
	movem.l	%d2-%d7/%a2-%a6, %sp@-
	clr.l	%sp@-
	move.l	%sp@(56), %sp@-
	move.l	%sp@(56), %sp@-
	move.w	#5, %sp@-
	.short	0xff4b
	lea	%sp@(14), %sp
	movem.l	%sp@+, %d2-%d7/%a2-%a6
	rts
