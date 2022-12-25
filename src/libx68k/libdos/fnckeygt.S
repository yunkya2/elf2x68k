| void _dos_fnckeygt (int, char *);
.text
.even
.global _dos_fnckeygt
.type _dos_fnckeygt,@function
_dos_fnckeygt:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff21
	addq.l	#6, %sp
	rts
