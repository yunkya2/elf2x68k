| int _dos_consns (void);
.text
.even
.global _dos_consns
.type _dos_consns,@function
_dos_consns:
	.short	0xff10
	rts
