| int _dos_wait (void);
.text
.even
.global _dos_wait
.type _dos_wait,@function
_dos_wait:
	.short	0xff4d
	rts
