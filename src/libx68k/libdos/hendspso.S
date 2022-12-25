| int _dos_hendspso (void);
.text
.even
.global _dos_hendspso
.type _dos_hendspso,@function
_dos_hendspso:
	move.w	#8, %sp@-
	.short	0xff18
	addq.l	#2, %sp
	rts
