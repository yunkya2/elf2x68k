| __dead void _dos_keeppr (int, int);
.text
.even
.global _dos_keeppr
.type _dos_keeppr,@function
_dos_keeppr:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff31
