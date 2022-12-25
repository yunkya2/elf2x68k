| int _dos_getchar (void);
.text
.even
.global _dos_getchar
.type _dos_getchar,@function
_dos_getchar:
	.short	0xff01
	rts
