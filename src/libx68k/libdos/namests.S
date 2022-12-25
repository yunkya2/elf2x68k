| int _dos_namests (const char *, struct _dos_namestbuf *);
.text
.even
.global _dos_namestbuf
.type _dos_namestbuf,@function
_dos_namestbuf:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff29
	addq.l	#8, %sp
	rts
