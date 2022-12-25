| int _dos_gettim2 (void);
.text
.even
.global _dos_gettim2
.type _dos_gettim2,@function
_dos_gettim2:
	.short	0xff27
	rts
