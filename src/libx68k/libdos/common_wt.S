| int _dos_common_wt (const char *, int, const char *, int);
.text
.even
.global _dos_common_wt
.type _dos_common_wt,@function
_dos_common_wt:
	movem.l	%sp@(4), %d0-%d1/%a0-%a1
	movem.l	%d0-%d1/%a0-%a1, %sp@-
	move.w	#2, %sp@-
	.short	0xff85
	lea	%sp@(18), %sp
	rts
