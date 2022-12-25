| int _dos_s_mfree (void *);
.text
.even
.global _dos_s_mfree
.type _dos_s_mfree,@function
_dos_s_mfree:
	move.l	%sp@(4), %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xffae
	bras	3f
2:
	.short	0xff7e
3:
	addq.l	#4, %sp
	rts
