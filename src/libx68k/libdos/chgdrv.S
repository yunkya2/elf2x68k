| int _dos_chgdrv (int);
.text
.even
.global _dos_chgdrv
.type _dos_chgdrv,@function
_dos_chgdrv:
	move.w	%sp@(6), %sp@-
	.short	0xff0e
	addq.l	#2, %sp
	rts
