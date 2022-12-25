| void _iocs_b_era_st (void);
.text
.even
.global _iocs_b_era_st
.type _iocs_b_era_st,@function
_iocs_b_era_st:
	moveq	#1, %d1
	moveq	#0x2b, %d0
	trap	#15
	rts
