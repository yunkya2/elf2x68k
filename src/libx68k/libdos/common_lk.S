| int _dos_common_lk (const char *, int, int, int);
.text
.even
.global _dos_common_lk
.type _dos_common_lk,@function
_dos_common_lk:
	movem.l	%sp@(4), %d0-%d1/%a0-%a1
	movem.l	%d0-%d1/%a0-%a1, %sp@-
	move.w	#3, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff85
	bras	3f
2:
	.short	0xff55
3:
	lea	%sp@(18), %sp
	rts
