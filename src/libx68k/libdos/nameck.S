| int _dos_nameck (const char *, struct _dos_nameckbuf *);
.text
.even
.global _dos_nameck
.type _dos_nameck,@function
_dos_nameck:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff37
	addq.l	#8, %sp
	rts
