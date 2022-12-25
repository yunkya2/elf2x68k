| int _dos_hendspmp (int, const char *);
.text
.even
.global _dos_hendspmp
.type _dos_hendspmp,@function
_dos_hendspmp:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	move.w	#1, %sp@-
	.short	0xff18
	addq.l	#8, %sp
	rts
