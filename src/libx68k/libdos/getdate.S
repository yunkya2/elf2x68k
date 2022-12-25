| int _dos_getdate (void);
.text
.even
.global _dos_getdate
.type _dos_getdate,@function
_dos_getdate:
	.short	0xff2a
	rts
