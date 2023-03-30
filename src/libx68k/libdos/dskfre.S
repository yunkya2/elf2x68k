| int _dos_dskfre (int, struct _dos_freeinf *);
.text
.even
.global _dos_dskfre
.type _dos_dskfre,@function
_dos_dskfre:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff36
	addq.l	#6, %sp
	rts
