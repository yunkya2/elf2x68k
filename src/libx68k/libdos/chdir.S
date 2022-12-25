| int _dos_chdir (const char *);
.text
.even
.global _dos_chdir
.type _dos_chdir,@function
_dos_chdir:
	move.l	%sp@(4), %sp@-
	.short	0xff3b
	addq.l	#4, %sp
	rts
