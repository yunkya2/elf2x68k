| int _dos_unlock (int, int, int);
.text
.even
.global _dos_unlock
.type _dos_unlock,@function
_dos_unlock:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	move.w	#1, %sp@-
	.short	0xff8c
	lea	%sp@(12), %sp
	rts
