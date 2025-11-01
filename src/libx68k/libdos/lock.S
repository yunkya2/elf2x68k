| int _dos_lock (int, int, int);
.text
.even
.global _dos_lock
.type _dos_lock,@function
_dos_lock:
	move.l	%sp@(12), %sp@-
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	clr.w	%sp@-
	.short	0xff8c
	lea	%sp@(12), %sp
	rts
