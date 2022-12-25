| int _dos_get_pr (int, struct _dos_prcptr *);
.text
.even
.global _dos_prcptr
.type _dos_prcptr,@function
_dos_prcptr:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xfffa
	addq.l	#6, %sp
	rts
