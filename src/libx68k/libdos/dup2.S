| int _dos_dup2 (int, int);
.text
.even
.global _dos_dup2
.type _dos_dup2,@function
_dos_dup2:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	.short	0xff46
	addq.l	#4, %sp
	rts
