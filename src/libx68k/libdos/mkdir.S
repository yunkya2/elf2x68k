| int _dos_mkdir (const char *);
.text
.even
.global _dos_mkdir
.type _dos_mkdir,@function
_dos_mkdir:
	move.l	%sp@(4), %sp@-
	.short	0xff39
	addq.l	#4, %sp
	rts
