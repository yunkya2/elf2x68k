| int _dos_getdpb (int, struct _dos_dpbptr *);
.text
.even
.global _dos_getdpb
.type _dos_getdpb,@function
_dos_getdpb:
	move.l	%sp@(8), %sp@-
	move.w	%sp@(10), %sp@-
	.short	0xff32
	addq.l	#6, %sp
	rts
