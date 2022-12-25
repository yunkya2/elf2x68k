| __dead void _dos_errabort (void);
.text
.even
.global _dos_errabort
.type _dos_errabort,@function
_dos_errabort:
	.short	0xfff2
