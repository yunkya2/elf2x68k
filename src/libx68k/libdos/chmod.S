| _dos_mode_t _dos_chmod (const char *, _dos_mode_t);
.text
.even
.global _dos_chmod
.type _dos_chmod,@function
_dos_chmod:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff43
	addq.l	#6, %sp
	rts
