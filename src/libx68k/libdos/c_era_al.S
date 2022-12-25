| int _dos_c_era_al (void);
.text
.even
.global _dos_c_era_al
.type _dos_c_era_al,@function
_dos_c_era_al:
	move.w	#2, %sp@-
	move.w	#11, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
