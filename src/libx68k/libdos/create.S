| int _dos_create (const char *, _dos_mode_t);
.text
.even
.global _dos_create
.type _dos_create,@function
_dos_create:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff3c
	addq.l	#6, %sp
	rts
