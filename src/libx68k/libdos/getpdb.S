| struct _dos_psp *_dos_getpdb (void);
.text
.even
.global _dos_getpdb
.type _dos_getpdb,@function
_dos_getpdb:
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff81
	bras	3f
2:
	.short	0xff51
3:
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
