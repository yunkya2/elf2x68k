| void _dos_fnckeyst (int, const char *);
.text
.even
.global _dos_fnckeyst
.type _dos_fnckeyst,@function
_dos_fnckeyst:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %d0
	or.w	#0x100, %d0
	move.w	%d0, %sp@-
	.short	0xff21
	addq.l	#6, %sp
	rts
