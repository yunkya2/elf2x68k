| int _dos_fatchk (const char *, unsigned short *);
.text
.even
.global _dos_fatchk
.type _dos_fatchk,@function
_dos_fatchk:
	move.l	%sp@(8), %sp@-
	move.l	%sp@(8), %sp@-
	.short	0xff17
	addq.l	#8, %sp
	rts
