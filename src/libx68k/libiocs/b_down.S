| void _iocs_b_down (int);
.text
.even
.global _iocs_b_down
.type _iocs_b_down,@function
_iocs_b_down:
	move.l	%sp@(4), %d1
	moveq	#0x27, %d0
	trap	#15
	rts
