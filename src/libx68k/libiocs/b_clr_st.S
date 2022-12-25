| void _iocs_b_clr_st (void);
.text
.even
.global _iocs_b_clr_st
.type _iocs_b_clr_st,@function
_iocs_b_clr_st:
	moveq	#1, %d1
	moveq	#0x2a, %d0
	trap	#15
	rts
