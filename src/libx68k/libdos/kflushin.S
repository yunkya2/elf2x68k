| int _dos_kflushin (void);
.text
.even
.global _dos_kflushin
.type _dos_kflushin,@function
_dos_kflushin:
	move.w	#7, %sp@-
	.short	0xff0c
	addq.l	#2, %sp
	rts
