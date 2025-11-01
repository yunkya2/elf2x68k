| int _dos_fflush_set (int);
.text
.even
.global _dos_fflush_set
.type _dos_fflush_set,@function
_dos_fflush_set:
	move.w	%sp@(6), %sp@-
	.short	0xffaa
	addq.l	#2, %sp
	rts
