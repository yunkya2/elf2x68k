| int _dos_namests (const char *, struct _dos_namestbuf *);
.text
.even
.global _dos_namests
.type _dos_namests,@function
_dos_namests:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff29
	addq.l	#8, %sp
	rts
