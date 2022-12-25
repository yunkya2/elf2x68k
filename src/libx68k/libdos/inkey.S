| int _dos_inkey (void);
.text
.even
.global _dos_inkey
.type _dos_inkey,@function
_dos_inkey:
	.short	0xff07
	rts
