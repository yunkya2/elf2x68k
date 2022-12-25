| void _dos_hendspmc (void);
.text
.even
.global _dos_hendspmc
.type _dos_hendspmc,@function
_dos_hendspmc:
	move.w	#3, %sp@-
	.short	0xff18
	addq.l	#2, %sp
	rts
