| struct _dos_indos *_dos_indosflg (void);
.text
.even
.global _dos_indosflg
.type _dos_indosflg,@function
_dos_indosflg:
	.short	0xfff5
#ifdef __SVR4_ABI__
	movea.l	%d0, %a0
#endif
	rts
