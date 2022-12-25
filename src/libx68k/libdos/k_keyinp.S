| int _dos_k_keyinp (void);
.text
.even
.global _dos_k_keyinp
.type _dos_k_keyinp,@function
_dos_k_keyinp:
	clr.w	%sp@-
	.short	0xff24
	addq.l	#2, %sp
	rts
