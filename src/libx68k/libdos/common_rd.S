| int _dos_common_rd (const char *, int, char *, int);
.text
.even
.global _dos_common_rd
.type _dos_common_rd,@function
_dos_common_rd:
	movem.l	%sp@(4), %d0-%d1/%a0-%a1
	movem.l	%d0-%d1/%a0-%a1, %sp@-
	move.w	#1, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff85
	bras	3f
2:
	.short	0xff55
3:
	lea	%sp@(18), %sp
	rts
