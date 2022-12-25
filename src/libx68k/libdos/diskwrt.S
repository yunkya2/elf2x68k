| void _dos_diskwrt (const void *, int, int, int);
.text
.even
.global _dos_diskwrt
.type _dos_diskwrt,@function
_dos_diskwrt:
	move.w	%sp@(18), %sp@-
	move.w	%sp@(16), %sp@-
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	.short	0xfff4
	lea	%sp@(10), %sp
	rts
