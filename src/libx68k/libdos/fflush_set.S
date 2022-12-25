| int _dos_fflush_set (int);
.text
.even
.global _dos_fflush_set
.type _dos_fflush_set,@function
_dos_fflush_set:
	move.w	%sp@(6), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xffaa
	bras	3f
2:
	.short	0xff7a
3:
	addq.l	#2, %sp
	rts
