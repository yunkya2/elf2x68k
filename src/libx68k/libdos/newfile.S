| int _dos_newfile (const char *, _dos_mode_t);
.text
.even
.global _dos_newfile
.type _dos_newfile,@function
_dos_newfile:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff8b
	addq.l	#6, %sp
	rts
