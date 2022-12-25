| void _iocs_b_del (int);
.text
.even
.global _iocs_b_del
.type _iocs_b_del,@function
_iocs_b_del:
	move.l	%sp@(4), %d1
	moveq	#0x2d, %d0
	trap	#15
	rts
