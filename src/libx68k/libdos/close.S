| int _dos_close (int);
.text
.even
.global _dos_close
.type _dos_close,@function
_dos_close:
	move.w	%sp@(6), %sp@-
	.short	0xff3e
	addq.l	#2, %sp
	rts
