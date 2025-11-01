| int _dos_verifyg (void);
.text
.even
.global _dos_verifyg
.type _dos_verifyg,@function
_dos_verifyg:
	.short	0xff84
	rts
