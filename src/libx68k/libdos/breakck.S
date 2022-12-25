| int _dos_breakck (int);
.text
.even
.global _dos_breakck
.type _dos_breakck,@function
_dos_breakck:
	move.w	%sp@(6), %sp@-
	.short	0xff33
	addq.l	#2, %sp
	rts
