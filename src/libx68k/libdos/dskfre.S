| int _dos_dskfre (int, struct _dos_freeinf *);
.text
.even
.global _dos_freeinf
.type _dos_freeinf,@function
_dos_freeinf:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff36
	addq.l	#6, %sp
	rts
