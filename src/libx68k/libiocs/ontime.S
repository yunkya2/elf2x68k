| struct iocs_time _iocs_ontime (void);
.text
.even
.global _iocs_ontime
.type _iocs_ontime,@function
_iocs_ontime:
	moveq	#0x7f, %d0
	trap	#15
	rts
