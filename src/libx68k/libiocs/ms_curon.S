| void _iocs_ms_curon (void);
.text
.even
.global _iocs_ms_curon
.type _iocs_ms_curon,@function
_iocs_ms_curon:
	moveq	#0x71, %d0
	trap	#15
	rts
