| void _dos_allclose (void);
.text
.even
.global _dos_allclose
.type _dos_allclose,@function
_dos_allclose:
	.short	0xff1f
	rts
