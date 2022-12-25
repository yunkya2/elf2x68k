| int _dos_execonly (void *);
.text
.even
.global _dos_execonly
.type _dos_execonly,@function
_dos_execonly:
	movem.l	%d2-%d7/%a2-%a6, %sp@-
	move.l	%sp@(48), %sp@-
	move.w	#4, %sp@-
	.short	0xff4b
	addq.l	#6, %sp
	movem.l	%sp@+, %d2-%d7/%a2-%a6
	rts
