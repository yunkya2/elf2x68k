| int _iocs_lof232c (void);
.text
.even
.global _iocs_lof232c
.type _iocs_lof232c,@function
_iocs_lof232c:
	moveq	#0x31, %d0
	trap	#15
	rts
