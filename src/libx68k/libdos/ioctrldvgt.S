| int _dos_ioctrldvgt (int);
.text
.even
.global _dos_ioctrldvgt
.type _dos_ioctrldvgt,@function
_dos_ioctrldvgt:
	move.w	%sp@(6), %sp@-
	move.w	#9, %sp@-
	.short	0xff44
	addq.l	#4, %sp
	rts
