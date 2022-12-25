| int _dos_ioctrlos (int);
.text
.even
.global _dos_ioctrlos
.type _dos_ioctrlos,@function
_dos_ioctrlos:
	move.w	%sp@(6), %sp@-
	move.w	#7, %sp@-
	.short	0xff44
	addq.l	#4, %sp
	rts
