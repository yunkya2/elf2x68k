| int _iocs_vdispst (const void *, int, int);
.text
.even
.global _iocs_vdispst
.type _iocs_vdispst,@function
_iocs_vdispst:
	movea.l	%sp@(4), %a1
	moveq	#0, %d1
	move.b	%sp@(11), %d1
	lsl.w	#8, %d1
	move.b	%sp@(15), %d1
	moveq	#0x6c, %d0
	trap	#15
	rts
