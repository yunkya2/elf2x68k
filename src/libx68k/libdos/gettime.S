| int _dos_gettime (void);
.text
.even
.global _dos_gettime
.type _dos_gettime,@function
_dos_gettime:
	.short	0xff2c
	rts
