| int _dos_verifyg (void);
.text
.even
.global _dos_verifyg
.type _dos_verifyg,@function
_dos_verifyg:
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff84
	bras	3f
2:
	.short	0xff54
3:
	rts
