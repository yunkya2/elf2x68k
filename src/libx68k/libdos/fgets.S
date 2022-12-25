| int _dos_fgets (struct _dos_inpptr *, int);
.text
.even
.global _dos_inpptr
.type _dos_inpptr,@function
_dos_inpptr:
	move.w	%sp@(10), %sp@-
	move.l	%sp@(6), %sp@-
	.short	0xff1c
	addq.l	#6, %sp
	rts
