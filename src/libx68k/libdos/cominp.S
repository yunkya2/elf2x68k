| int _dos_cominp (void);
.text
.even
.global _dos_cominp
.type _dos_cominp,@function
_dos_cominp:
	.short	0xff03
	rts
