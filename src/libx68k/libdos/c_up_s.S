| int _dos_c_up_s (void);
.text
.even
.global _dos_c_up_s
.type _dos_c_up_s,@function
_dos_c_up_s:
	move.w	#5, %sp@-
	.short	0xff23
	addq.l	#2, %sp
	rts
