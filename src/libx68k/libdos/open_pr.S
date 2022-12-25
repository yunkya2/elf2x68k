| int _dos_open_pr (const char *, int, int, int, int, int, struct _dos_prcctrl *, long);
.text
.even
.global _dos_open_pr
.type _dos_open_pr,@function
_dos_open_pr:
	movem.l	%sp@(20), %d0-%d1/%a0-%a1
	movem.l	%d1/%a0-%a1, %sp@-
	move.w	%d0, %sp@-
	move.l	%sp@(32), %sp@-
	move.l	%sp@(32), %sp@-
	move.w	%sp@(34), %sp@-
	move.l	%sp@(30), %sp@-
	.short	0xfff8
	lea	%sp@(28), %sp
	rts
