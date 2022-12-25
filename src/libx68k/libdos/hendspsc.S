| void _dos_hendspsc (void);
.text
.even
.global _dos_hendspsc
.type _dos_hendspsc,@function
_dos_hendspsc:
	move.w	#11, %sp@-
	.short	0xff18
	addq.l	#2, %sp
	rts
