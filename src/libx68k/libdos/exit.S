| __dead void _dos_exit (void);
.text
.even
.global _dos_exit
.type _dos_exit,@function
_dos_exit:
	.short	0xff00
