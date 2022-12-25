| int _dos_mfree (void *);
.text
.even
.global _dos_mfree
.type _dos_mfree,@function
_dos_mfree:
	move.l	%sp@(4), %sp@-
	.short	0xff49
	addq.l	#4, %sp
	rts
