| int _dos_ioctrlrtset (int, int);
.text
.even
.global _dos_ioctrlrtset
.type _dos_ioctrlrtset,@function
_dos_ioctrlrtset:
	move.w	%sp@(10), %sp@-
	move.w	%sp@(8), %sp@-
	move.w	#11, %sp@-
	.short	0xff44
	addq.l	#6, %sp
	rts
