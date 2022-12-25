| int _iocs_sp_on (void);
.text
.even
.global _iocs_sp_on
.type _iocs_sp_on,@function
_iocs_sp_on:
	moveq	#0xffffffc1, %d0
	trap	#15
	rts
