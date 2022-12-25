| int _iocs_ms_getdt (void);
.text
.even
.global _iocs_ms_getdt
.type _iocs_ms_getdt,@function
_iocs_ms_getdt:
	moveq	#0x74, %d0
	trap	#15
	rts
