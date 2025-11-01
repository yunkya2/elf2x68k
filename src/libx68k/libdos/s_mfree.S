| int _dos_s_mfree (void *);
.text
.even
.global _dos_s_mfree
.type _dos_s_mfree,@function
_dos_s_mfree:
	move.l	%sp@(4), %sp@-
	.short	0xffae
	addq.l	#4, %sp
	rts
