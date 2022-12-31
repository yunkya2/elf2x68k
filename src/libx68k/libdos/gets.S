| int _dos_gets (struct _dos_inpptr *);
.text
.even
.global _dos_gets
.type _dos_gets,@function
_dos_gets:
	move.l	%sp@(4), %sp@-
	.short	0xff0a
	addq.l	#4, %sp
	rts
