| int _dos_ioctrlis (int);
.text
.even
.global _dos_ioctrlis
.type _dos_ioctrlis,@function
_dos_ioctrlis:
	move.w	%sp@(6), %sp@-
	move.w	#6, %sp@-
	.short	0xff44
	addq.l	#4, %sp
	rts
