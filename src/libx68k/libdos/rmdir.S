| int _dos_rmdir (const char *);
.text
.even
.global _dos_rmdir
.type _dos_rmdir,@function
_dos_rmdir:
	move.l	%sp@(4), %sp@-
	.short	0xff3a
	addq.l	#4, %sp
	rts
