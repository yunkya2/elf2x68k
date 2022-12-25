| void _iocs_ms_curof (void);
.text
.even
.global _iocs_ms_curof
.type _iocs_ms_curof,@function
_iocs_ms_curof:
	moveq	#0x72, %d0
	trap	#15
	rts
