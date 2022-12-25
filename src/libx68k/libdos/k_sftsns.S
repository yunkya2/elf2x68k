| int _dos_k_sftsns (void);
.text
.even
.global _dos_k_sftsns
.type _dos_k_sftsns,@function
_dos_k_sftsns:
	move.w	#2, %sp@-
	.short	0xff24
	addq.l	#2, %sp
	rts
