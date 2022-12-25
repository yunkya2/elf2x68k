| int _dos_c_cls_st (void);
.text
.even
.global _dos_c_cls_st
.type _dos_c_cls_st,@function
_dos_c_cls_st:
	move.w	#1, %sp@-
	move.w	#10, %sp@-
	.short	0xff23
	addq.l	#4, %sp
	rts
