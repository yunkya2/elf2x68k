| void _iocs_b_era_al (void);
.text
.even
.global _iocs_b_era_al
.type _iocs_b_era_al,@function
_iocs_b_era_al:
	moveq	#2, %d1
	moveq	#0x2b, %d0
	trap	#15
	rts
