| int _dos_hendspmr (int, const char *);
.text
.even
.global _dos_hendspmr
.type _dos_hendspmr,@function
_dos_hendspmr:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	move.w	#2, %sp@-
	.short	0xff18
	addq.l	#8, %sp
	rts
