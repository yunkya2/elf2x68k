| int _dos_common_del (const char *);
.text
.even
.global _dos_common_del
.type _dos_common_del,@function
_dos_common_del:
	move.l	%sp@(4), %sp@-
	move.w	#5, %sp@-
	.short	0xff85
	addq.l	#6, %sp
	rts
