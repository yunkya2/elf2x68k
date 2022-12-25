| int _dos_hendspmo (void);
.text
.even
.global _dos_hendspmo
.type _dos_hendspmo,@function
_dos_hendspmo:
	clr.w	%sp@-
	.short	0xff18
	addq.l	#2, %sp
	rts
