| void _iocs_b_clr_ed (void);
.text
.even
.global _iocs_b_clr_ed
.type _iocs_b_clr_ed,@function
_iocs_b_clr_ed:
	moveq	#0, %d1
	moveq	#0x2a, %d0
	trap	#15
	rts
