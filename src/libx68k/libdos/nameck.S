| int _dos_nameck (const char *, struct _dos_nameckbuf *);
.text
.even
.global _dos_nameckbuf
.type _dos_nameckbuf,@function
_dos_nameckbuf:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff37
	addq.l	#8, %sp
	rts
