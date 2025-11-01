| int _dos_rassign (const char *);
.text
.even
.global _dos_rassign
.type _dos_rassign,@function
_dos_rassign:
	move.l	%sp@(4), %sp@-
	move.w	#4, %sp@-
	.short	0xff8f
	addq.l	#6, %sp
	rts
