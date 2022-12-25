| int _dos_c_ins (int);
.text
.even
.global _dos_c_ins
.type _dos_c_ins,@function
_dos_c_ins:
	move.w	%sp@(6), %sp@-
	move.w	#12, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
