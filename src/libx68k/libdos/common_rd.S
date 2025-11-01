| int _dos_common_rd (const char *, int, char *, int);
.text
.even
.global _dos_common_rd
.type _dos_common_rd,@function
_dos_common_rd:
	movem.l	%sp@(4), %d0-%d1/%a0-%a1
	movem.l	%d0-%d1/%a0-%a1, %sp@-
	move.w	#1, %sp@-
	.short	0xff85
	lea	%sp@(18), %sp
	rts
