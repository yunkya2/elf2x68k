| int _dos_cinsns (void);
.text
.even
.global _dos_cinsns
.type _dos_cinsns,@function
_dos_cinsns:
	.short	0xff12
	rts
