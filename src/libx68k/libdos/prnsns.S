| int _dos_prnsns (void);
.text
.even
.global _dos_prnsns
.type _dos_prnsns,@function
_dos_prnsns:
	.short	0xff11
	rts
