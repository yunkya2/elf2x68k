| int _dos_kflushgs (struct _dos_inpptr *);
.text
.even
.global _dos_kflushgs
.type _dos_kflushgs,@function
_dos_kflushgs:
	move.l	%sp@(4), %sp@-
	move.w	#10, %sp@-
	.short	0xff0c
	addq.l	#6, %sp
	rts
