| int _dos_write (int, const char *, int);
.text
.even
.global _dos_write
.type _dos_write,@function
_dos_write:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	.short	0xff40
	lea	%sp@(10), %sp
	rts
