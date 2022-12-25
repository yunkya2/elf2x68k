| void _iocs_b_left (int);
.text
.even
.global _iocs_b_left
.type _iocs_b_left,@function
_iocs_b_left:
	move.l	%sp@(4), %d1
	moveq	#0x29, %d0
	trap	#15
	rts
