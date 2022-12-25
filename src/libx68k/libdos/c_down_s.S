| int _dos_c_down_s (void);
.text
.even
.global _dos_c_down_s
.type _dos_c_down_s,@function
_dos_c_down_s:
	move.w	#4, %sp@-
	.short	0xff23
	addq.l	#2, %sp
	rts
