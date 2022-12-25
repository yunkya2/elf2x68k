| int _dos_c_cls_ed (void);
.text
.even
.global _dos_c_cls_ed
.type _dos_c_cls_ed,@function
_dos_c_cls_ed:
	clr.w	%sp@-
	move.w	#10, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
