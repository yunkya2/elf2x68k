| int _dos_send_pr (int, int, int, char *, long);
.text
.even
.global _dos_send_pr
.type _dos_send_pr,@function
_dos_send_pr:
	move.l	%sp@(20), %sp@-
	move.l	%sp@(20), %sp@-
	move.w	%sp@(22), %sp@-
	move.w	%sp@(20), %sp@-
	move.w	%sp@(18), %sp@-
	.short	0xfffd
	lea	%sp@(14), %sp
	rts
