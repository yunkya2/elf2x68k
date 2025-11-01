| int _dos_getassign (const char *, char *);
.text
.even
.global _dos_getassign
.type _dos_getassign,@function
_dos_getassign:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	clr.w	%sp@-
	.short	0xff8f
	lea	%sp@(10), %sp
	rts
