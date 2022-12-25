| int _dos_ioctrldvctl (int, int, char *);
.text
.even
.global _dos_ioctrldvctl
.type _dos_ioctrldvctl,@function
_dos_ioctrldvctl:
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	move.w	%sp@(12), %sp@-
	move.w	#12, %sp@-
	.short	0xff44
	lea	%sp@(10), %sp
	rts
