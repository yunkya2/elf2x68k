| int _dos_k_keysns (void);
.text
.even
.global _dos_k_keysns
.type _dos_k_keysns,@function
_dos_k_keysns:
	move.w	#1, %sp@-
	.short	0xff24
	addq.l	#2, %sp
	rts
