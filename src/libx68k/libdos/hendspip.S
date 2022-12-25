| int _dos_hendspip (int, const char *);
.text
.even
.global _dos_hendspip
.type _dos_hendspip,@function
_dos_hendspip:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	move.w	#5, %sp@-
	.short	0xff18
	addq.l	#8, %sp
	rts
