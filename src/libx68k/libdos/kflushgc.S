| int _dos_kflushgc (void);
.text
.even
.global _dos_kflushgc
.type _dos_kflushgc,@function
_dos_kflushgc:
	move.w	#8, %sp@-
	.short	0xff0c
	addq.l	#2, %sp
	rts
