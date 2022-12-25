| void _dos_drvxchg (int, int);
.text
.even
.global _dos_drvxchg
.type _dos_drvxchg,@function
_dos_drvxchg:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	.short	0xff34
	addq.l	#4, %sp
	rts
