| void _iocs_s_reset (void);
.text
.even
.global _iocs_s_reset
.type _iocs_s_reset,@function
_iocs_s_reset:
	moveq	#0, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	rts
