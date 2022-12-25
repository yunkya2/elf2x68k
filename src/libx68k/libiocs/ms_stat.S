| int _iocs_ms_stat (void);
.text
.even
.global _iocs_ms_stat
.type _iocs_ms_stat,@function
_iocs_ms_stat:
	moveq	#0x73, %d0
	trap	#15
	rts
