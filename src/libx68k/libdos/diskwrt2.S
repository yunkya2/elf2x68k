| void _dos_diskwrt2 (const void *, int, int, int);
.text
.even
.global _dos_diskwrt2
.type _dos_diskwrt2,@function
_dos_diskwrt2:
	move.l	%sp@(16), %sp@-
	move.l	%sp@(16), %sp@-
	move.w	%sp@(18), %sp@-
	move.l	%sp@(14), %d0
	bset	#31, %d0
	move.l	%d0, %sp@-
	.short	0xfff4
	lea	%sp@(14), %sp
	rts
