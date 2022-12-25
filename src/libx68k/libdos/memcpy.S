| int _dos_memcpy (void *, void *, int);
.text
.even
.global _dos_memcpy
.type _dos_memcpy,@function
_dos_memcpy:
.global _dos_bus_err
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	move.l	%sp@(10), %sp@-
	.short	0xfff7
	lea	%sp@(10), %sp
	rts
