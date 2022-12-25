| void _dos_verify (int);
.text
.even
.global _dos_verify
.type _dos_verify,@function
_dos_verify:
	move.w	%sp@(6), %sp@-
	.short	0xff2e
	addq.l	#2, %sp
	rts
