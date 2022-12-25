| void _dos_diskred (void *, int, int, int);
.text
.even
.global _dos_diskred
.type _dos_diskred,@function
_dos_diskred:
	move.w	%sp@(18), %sp@-
	move.w	%sp@(16), %sp@-
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	.short	0xfff3
	lea	%sp@(10), %sp
	rts
