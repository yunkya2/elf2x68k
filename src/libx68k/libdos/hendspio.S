| int _dos_hendspio (void);
.text
.even
.global _dos_hendspio
.type _dos_hendspio,@function
_dos_hendspio:
	move.w	#4, %sp@-
	.short	0xff18
	addq.l	#2, %sp
	rts
