| int _dos_gets (struct _dos_inpptr *);
.text
.even
.global _dos_inpptr
.type _dos_inpptr,@function
_dos_inpptr:
	move.l	%sp@(4), %sp@-
	.short	0xff0a
	addq.l	#4, %sp
	rts
