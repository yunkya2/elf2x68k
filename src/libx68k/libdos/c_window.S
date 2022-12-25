| int _dos_c_window (int, int);
.text
.even
.global _dos_c_window
.type _dos_c_window,@function
_dos_c_window:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	move.w	#15, %sp@-
	.short	0xff23
	addq.l	#6, %sp
	rts
