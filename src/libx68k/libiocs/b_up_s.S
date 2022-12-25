| void _iocs_b_up_s (void);
.text
.even
.global _iocs_b_up_s
.type _iocs_b_up_s,@function
_iocs_b_up_s:
	moveq	#0x25, %d0
	trap	#15
	rts
