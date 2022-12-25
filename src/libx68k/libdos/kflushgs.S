| int _dos_kflushgs (struct _dos_inpptr *);
.text
.even
.global _dos_inpptr
.type _dos_inpptr,@function
_dos_inpptr:
	move.l	%sp@(4), %sp@-
	move.w	#10, %sp@-
	.short	0xff0c
	addq.l	#6, %sp
	rts
