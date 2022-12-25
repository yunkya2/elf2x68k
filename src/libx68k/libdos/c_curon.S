| int _dos_c_curon (void);
.text
.even
.global _dos_c_curon
.type _dos_c_curon,@function
_dos_c_curon:
	move.w	#17, %sp@-
	.short	0xff23
	addq.l	#2, %sp
	rts
