| void _dos_diskred2 (void *, int, int, int);
.text
.even
.global _dos_diskred2
.type _dos_diskred2,@function
_dos_diskred2:
	move.l	%sp@(16), %sp@-
	move.l	%sp@(16), %sp@-
	move.w	%sp@(18), %sp@-
	move.l	%sp@(14), %d0
	bset	#31, %d0
	move.l	%d0, %sp@-
	.short	0xfff3
	lea	%sp@(14), %sp
	rts
