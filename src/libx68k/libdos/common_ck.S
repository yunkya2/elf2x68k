| int _dos_common_ck (const char *);
.text
.even
.global _dos_common_ck
.type _dos_common_ck,@function
_dos_common_ck:
	move.l	%sp@(4), %sp@-
	clr.w	%sp@-
	.short	0xff85
	addq.l	#6, %sp
	rts
