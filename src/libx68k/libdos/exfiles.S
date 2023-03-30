| int _dos_exfiles (struct _dos_exfilbuf *, const char *, int);
.text
.even
.global _dos_exfiles
.type _dos_exfiles,@function
_dos_exfiles:
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	move.l	%sp@(10), %d0
	bset	#31, %d0
	move.l	%d0, %sp@-
	.short	0xff4e
	lea	%sp@(10), %sp
	rts
