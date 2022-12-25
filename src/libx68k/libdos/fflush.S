| void _dos_fflush (void);
.text
.even
.global _dos_fflush
.type _dos_fflush,@function
_dos_fflush:
	.short	0xff0d
	rts
