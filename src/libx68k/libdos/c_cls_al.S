| int _dos_c_cls_al (void);
.text
.even
.global _dos_c_cls_al
.type _dos_c_cls_al,@function
_dos_c_cls_al:
	move.w	#2, %sp@-
	move.w	#10, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
