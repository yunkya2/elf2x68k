| void _iocs_b_era_ed (void);
.text
.even
.global _iocs_b_era_ed
.type _iocs_b_era_ed,@function
_iocs_b_era_ed:
	moveq	#0, %d1
	moveq	#0x2b, %d0
	trap	#15
	rts
