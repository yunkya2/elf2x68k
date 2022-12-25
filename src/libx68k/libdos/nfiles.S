| int _dos_nfiles (struct _dos_filbuf *);
.text
.even
.global _dos_filbuf
.type _dos_filbuf,@function
_dos_filbuf:
	move.l	%sp@(4), %sp@-
	.short	0xff4f
	addq.l	#4, %sp
	rts
