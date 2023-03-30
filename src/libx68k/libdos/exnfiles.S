| int _dos_exnfiles (struct _dos_exfilbuf *);
.text
.even
.global _dos_exnfiles
.type _dos_exnfiles,@function
_dos_exnfiles:
	move.l	%sp@(4), %d0
	bset	#31, %d0
	move.l	%d0, %sp@-
	.short	0xff4f
	addq.l	#4, %sp
	rts
