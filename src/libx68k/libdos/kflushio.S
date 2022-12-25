| int _dos_kflushio (int);
.text
.even
.global _dos_kflushio
.type _dos_kflushio,@function
_dos_kflushio:
	move.w	%sp@(6), %sp@-
	move.w	#6, %sp@-
	.short	0xff0c
	addq.l	#4, %sp
	rts
