| int _dos_load (const char *, const struct _dos_comline *, const char *);
.text
.even
.global _dos_load
.type _dos_load,@function
_dos_load:
	movem.l	%d2-%d7/%a2-%a6, %sp@-
	movem.l	%sp@(48), %d0-%d1/%a0
	movem.l	%d0-%d1/%a0, %sp@-
	move.w	#1, %sp@-
	.short	0xff4b
	lea	%sp@(14), %sp
	movem.l	%sp@+, %d2-%d7/%a2-%a6
	rts
