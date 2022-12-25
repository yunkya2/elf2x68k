| int _dos_ioctrlfdctl (int, int, char *);
.text
.even
.global _dos_ioctrlfdctl
.type _dos_ioctrlfdctl,@function
_dos_ioctrlfdctl:
	move.l	%sp@(12), %sp@-
	move.w	%sp@(14), %sp@-
	move.w	%sp@(12), %sp@-
	move.w	#13, %sp@-
	.short	0xff44
	lea	%sp@(10), %sp
	rts
