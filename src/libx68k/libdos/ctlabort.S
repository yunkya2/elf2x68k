| __dead void _dos_ctlabort (void);
.text
.even
.global _dos_ctlabort
.type _dos_ctlabort,@function
_dos_ctlabort:
	.short	0xfff1
