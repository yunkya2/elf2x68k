| int _dos_c_curoff (void);
.text
.even
.global _dos_c_curoff
.type _dos_c_curoff,@function
_dos_c_curoff:
	move.w	#18, %sp@-
	.short	0xff23
	addq.l	#2, %sp
	rts
