| int _dos_setdate (int);
.text
.even
.global _dos_setdate
.type _dos_setdate,@function
_dos_setdate:
	move.w	%sp@(6), %sp@-
	.short	0xff2b
	addq.l	#2, %sp
	rts
