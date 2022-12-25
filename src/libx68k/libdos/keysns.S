| int _dos_keysns (void);
.text
.even
.global _dos_keysns
.type _dos_keysns,@function
_dos_keysns:
	.short	0xff0b
	rts
