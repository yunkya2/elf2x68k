| int _dos_setblock (void *, int);
.text
.even
.global _dos_setblock
.type _dos_setblock,@function
_dos_setblock:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff4a
	addq.l	#8, %sp
	rts
