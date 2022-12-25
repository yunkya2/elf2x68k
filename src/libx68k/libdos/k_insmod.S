| void _dos_k_insmod (int);
.text
.even
.global _dos_k_insmod
.type _dos_k_insmod,@function
_dos_k_insmod:
	move.w	%sp@(6), %sp@-
	move.w	#4, %sp@-
	.short	0xff24
	addq.l	#4, %sp
	rts
