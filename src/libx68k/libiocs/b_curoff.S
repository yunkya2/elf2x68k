| void _iocs_b_curoff (void);
.text
.even
.global _iocs_b_curoff
.type _iocs_b_curoff,@function
_iocs_b_curoff:
	moveq	#0x1f, %d0
	trap	#15
	rts
