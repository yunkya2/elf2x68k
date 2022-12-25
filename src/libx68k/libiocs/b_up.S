| void _iocs_b_up (int);
.text
.even
.global _iocs_b_up
.type _iocs_b_up,@function
_iocs_b_up:
	move.l	%sp@(4), %d1
	moveq	#0x26, %d0
	trap	#15
	rts
