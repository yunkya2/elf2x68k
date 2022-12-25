| void _iocs_b_right (int);
.text
.even
.global _iocs_b_right
.type _iocs_b_right,@function
_iocs_b_right:
	move.l	%sp@(4), %d1
	moveq	#0x28, %d0
	trap	#15
	rts
