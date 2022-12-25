| int _dos_ioctrlfdgt (int);
.text
.even
.global _dos_ioctrlfdgt
.type _dos_ioctrlfdgt,@function
_dos_ioctrlfdgt:
	move.w	%sp@(6), %sp@-
	move.w	#10, %sp@-
	.short	0xff44
	addq.l	#4, %sp
	rts
