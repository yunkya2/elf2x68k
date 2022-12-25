| int _dos_kflushgp (void);
.text
.even
.global _dos_kflushgp
.type _dos_kflushgp,@function
_dos_kflushgp:
	move.w	#1, %sp@-
	.short	0xff0c
	addq.l	#2, %sp
	rts
