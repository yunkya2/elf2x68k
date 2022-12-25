| void _iocs_b_curon (void);
.text
.even
.global _iocs_b_curon
.type _iocs_b_curon,@function
_iocs_b_curon:
	moveq	#0x1e, %d0
	trap	#15
	rts
