| __dead void _dos_exit2 (int);
.text
.even
.global _dos_exit2
.type _dos_exit2,@function
_dos_exit2:
	move.w	%sp@(6), %sp@-
	.short	0xff4c
