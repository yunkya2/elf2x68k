| int __pure _dos_vernum (void);
.text
.even
.global _dos_vernum
.type _dos_vernum,@function
_dos_vernum:
	.short	0xff30
	rts
