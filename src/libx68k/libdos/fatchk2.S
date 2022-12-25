| int _dos_fatchk2 (const char *, unsigned short *, int);
.text
.even
.global _dos_fatchk2
.type _dos_fatchk2,@function
_dos_fatchk2:
	move.w	%sp@(14), %sp@-
	move.l	%sp@(10), %d0
	bset	#31, %d0
	move.l	%d0, %sp@-
	move.l	%sp@(10), %sp@-
	.short	0xff17
	lea	%sp@(10), %sp
	rts
