| int _dos_hendspsr (int, const char *);
.text
.even
.global _dos_hendspsr
.type _dos_hendspsr,@function
_dos_hendspsr:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	move.w	#10, %sp@-
	.short	0xff18
	addq.l	#8, %sp
	rts
