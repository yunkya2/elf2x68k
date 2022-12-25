| int _dos_common_del (const char *);
.text
.even
.global _dos_common_del
.type _dos_common_del,@function
_dos_common_del:
	move.l	%sp@(4), %sp@-
	move.w	#5, %sp@-
	cmpi.w	#0x200+14, _vernum+2	| 2.14
	bcss	2f
	.short	0xff85
	bras	3f
2:
	.short	0xff55
3:
	addq.l	#6, %sp
	rts
