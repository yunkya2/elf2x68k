| int _dos_k_keybit (int);
.text
.even
.global _dos_k_keybit
.type _dos_k_keybit,@function
_dos_k_keybit:
	move.w	%sp@(6), %sp@-
	move.w	#3, %sp@-
	.short	0xff24
	addq.l	#4, %sp
	rts
