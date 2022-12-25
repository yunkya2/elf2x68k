| void _iocs_b_ins (int);
.text
.even
.global _iocs_b_ins
.type _iocs_b_ins,@function
_iocs_b_ins:
	move.l	%sp@(4), %d1
	moveq	#0x2c, %d0
	trap	#15
	rts
