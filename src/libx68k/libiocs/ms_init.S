| void _iocs_ms_init (void);
.text
.even
.global _iocs_ms_init
.type _iocs_ms_init,@function
_iocs_ms_init:
	moveq	#0x70, %d0
	trap	#15
	rts
