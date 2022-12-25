| int _dos_fgetc (int);
.text
.even
.global _dos_fgetc
.type _dos_fgetc,@function
_dos_fgetc:
	move.w	%sp@(6), %sp@-
	.short	0xff1b
	addq.l	#2, %sp
	rts
