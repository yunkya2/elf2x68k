| int _dos_files (struct _dos_filbuf *, const char *, int);
.text
.even
.global _dos_filbuf
.type _dos_filbuf,@function
_dos_filbuf:
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	move.l	%sp@(10), %sp@-
	.short	0xff4e
	lea	%sp@(10), %sp
	rts
