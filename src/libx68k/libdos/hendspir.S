| int _dos_hendspir (int, const char *);
.text
.even
.global _dos_hendspir
.type _dos_hendspir,@function
_dos_hendspir:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	move.w	#6, %sp@-
	.short	0xff18
	addq.l	#8, %sp
	rts
