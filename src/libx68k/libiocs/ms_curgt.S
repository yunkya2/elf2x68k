| int _iocs_ms_curgt (void);
.text
.even
.global _iocs_ms_curgt
.type _iocs_ms_curgt,@function
_iocs_ms_curgt:
	moveq	#0x75, %d0
	trap	#15
	rts
