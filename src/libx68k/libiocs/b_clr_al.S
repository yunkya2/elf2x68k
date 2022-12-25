| void _iocs_b_clr_al (void);
.text
.even
.global _iocs_b_clr_al
.type _iocs_b_clr_al,@function
_iocs_b_clr_al:
	moveq	#2, %d1
	moveq	#0x2a, %d0
	trap	#15
	rts
