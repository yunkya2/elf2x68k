| void _iocs_sp_off (void);
.text
.even
.global _iocs_sp_off
.type _iocs_sp_off,@function
_iocs_sp_off:
	moveq	#0xffffffc2, %d0
	trap	#15
	rts
