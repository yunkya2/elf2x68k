| int _dos_makeassign (const char *, const char *, int);
.text
.even
.global _dos_makeassign
.type _dos_makeassign,@function
_dos_makeassign:
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %sp@-
	move.l	%sp@(10), %sp@-
	move.w	#1, %sp@-
	.short	0xff8f
	lea	%sp@(12), %sp
	rts
