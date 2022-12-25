| int _dos_coutsns (void);
.text
.even
.global _dos_coutsns
.type _dos_coutsns,@function
_dos_coutsns:
	.short	0xff13
	rts
