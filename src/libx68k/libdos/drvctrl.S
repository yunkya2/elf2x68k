| int _dos_drvctrl (int, int);
.text
.even
.global _dos_drvctrl
.type _dos_drvctrl,@function
_dos_drvctrl:
	move.b	%sp@(7), %d0
	lsl.w	#8, %d0
	move.b	%sp@(11), %d0
	move.w	%d0, %sp@-
	.short	0xff0f
	addq.l	#2, %sp
	rts
