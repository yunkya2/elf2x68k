| int _dos_getc (void);
.text
.even
.global _dos_getc
.type _dos_getc,@function
_dos_getc:
	.short	0xff08
	rts
