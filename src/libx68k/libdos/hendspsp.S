| int _dos_hendspsp (int, const char *);
.text
.even
.global _dos_hendspsp
.type _dos_hendspsp,@function
_dos_hendspsp:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	move.w	#9, %sp@-
	.short	0xff18
	addq.l	#8, %sp
	rts
