| int _dos_c_era_ed (void);
.text
.even
.global _dos_c_era_ed
.type _dos_c_era_ed,@function
_dos_c_era_ed:
	clr.w	%sp@-
	move.w	#11, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
