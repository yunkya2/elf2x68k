| int _dos_common_lk (const char *, int, int, int);
.text
.even
.global _dos_common_lk
.type _dos_common_lk,@function
_dos_common_lk:
	movem.l	%sp@(4), %d0-%d1/%a0-%a1
	movem.l	%d0-%d1/%a0-%a1, %sp@-
	move.w	#3, %sp@-
	.short	0xff85
	lea	%sp@(18), %sp
	rts
