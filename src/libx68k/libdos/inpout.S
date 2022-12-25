| int _dos_inpout (int);
.text
.even
.global _dos_inpout
.type _dos_inpout,@function
_dos_inpout:
	move.w	%sp@(6), %sp@-
	.short	0xff06
	addq.l	#2, %sp
	rts
