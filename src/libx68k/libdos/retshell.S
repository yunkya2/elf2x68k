| __dead void _dos_retshell (void);
.text
.even
.global _dos_retshell
.type _dos_retshell,@function
_dos_retshell:
.global _dos_exitvc
	.short	0xfff0
