| int _dos_suspend_pr (int);
.text
.even
.global _dos_suspend_pr
.type _dos_suspend_pr,@function
_dos_suspend_pr:
	move.w	%sp@(6), %sp@-
	.short	0xfffb
	addq.l	#2, %sp
	rts
