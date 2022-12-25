| int _dos_sleep_pr (long);
.text
.even
.global _dos_sleep_pr
.type _dos_sleep_pr,@function
_dos_sleep_pr:
	move.l	%sp@(4), %sp@-
	.short	0xfffc
	addq.l	#4, %sp
	rts
