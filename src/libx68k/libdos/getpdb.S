| struct _dos_psp *_dos_getpdb (void);
.text
.even
.global _dos_getpdb
.type _dos_getpdb,@function
_dos_getpdb:
	.short	0xff81
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
