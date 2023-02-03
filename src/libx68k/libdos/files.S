| int _dos_files (struct _dos_filbuf *, const char *, int);
.text
.even
.global _dos_files
.type _dos_files,@function
_dos_files:
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	move.l	%sp@(10), %sp@-
	.short	0xff4e
	lea	%sp@(10), %sp
	rts
