| int _dos_getss (struct _dos_inpptr *);
.text
.even
.global _dos_getss
.type _dos_getss,@function
_dos_getss:
	move.l	%sp@(4), %sp@-
	.short	0xff1a
	addq.l	#4, %sp
	rts
