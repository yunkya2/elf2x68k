| int _dos_settime (int);
.text
.even
.global _dos_settime
.type _dos_settime,@function
_dos_settime:
	move.w	%sp@(6), %sp@-
	.short	0xff2d
	addq.l	#2, %sp
	rts
