| void _iocs_b_down_s (void);
.text
.even
.global _iocs_b_down_s
.type _iocs_b_down_s,@function
_iocs_b_down_s:
	moveq	#0x24, %d0
	trap	#15
	rts
