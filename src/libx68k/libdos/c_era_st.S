| int _dos_c_era_st (void);
.text
.even
.global _dos_c_era_st
.type _dos_c_era_st,@function
_dos_c_era_st:
	move.w	#1, %sp@-
	move.w	#11, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
