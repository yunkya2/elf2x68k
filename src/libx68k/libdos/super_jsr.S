| void _dos_super_jsr (void (*)(void), struct _dos_dregs *, struct _dos_dregs *);
.text
.even
.global _dos_dregs
.type _dos_dregs,@function
_dos_dregs:
	movem.l	%d2-%d7/%a2-%a6, %sp@-
	move.l	%sp@(48), %sp@-
	movea.l	%sp@(56), %a0	| inregs
	movem.l	%a0@, %d0-%d7/%a0-%a6
	.short	0xfff6
	move.l	%a6, %sp@
	movea.l	%sp@(60), %a6	| outregs
	move.l	%sp@+, %a6@(56)
	movem.l	%d0-%d7/%a0-%a5, %a6@
	movem.l	%sp@+, %d2-%d7/%a2-%a6
	rts
