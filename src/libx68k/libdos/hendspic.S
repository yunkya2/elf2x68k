| void _dos_hendspic (int);
.text
.even
.global _dos_hendspic
.type _dos_hendspic,@function
_dos_hendspic:
	move.w	%sp@(6), %sp@-
	move.w	#7, %sp@-
	.short	0xff18
	addq.l	#4, %sp
	rts
