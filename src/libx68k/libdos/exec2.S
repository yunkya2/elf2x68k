| int _dos_exec2 (int, const char *, const char *, const char *);
.text
.even
.global _dos_exec2
.type _dos_exec2,@function
_dos_exec2:
	movem.l	%d2-%d7/%a2-%a6, %sp@-
	movem.l	%sp@(48), %d0-%d1/%a0-%a1
	movem.l	%d1/%a0-%a1, %sp@-
	move.w	%d0, %sp@-
	.short	0xff4b
	lea	%sp@(14), %sp
	movem.l	%sp@+, %d2-%d7/%a2-%a6
	rts
