| int _dos_curdrv (void);
.text
.even
.global _dos_curdrv
.type _dos_curdrv,@function
_dos_curdrv:
	.short	0xff19
	rts
