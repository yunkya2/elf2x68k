| int _dos_read (int, char *, int);
.text
.even
.global _dos_read
.type _dos_read,@function
_dos_read:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	.short	0xff3f
	lea	%sp@(10), %sp
	rts
