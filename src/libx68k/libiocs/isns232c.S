| int _iocs_isns232c (void);
.text
.even
.global _iocs_isns232c
.type _iocs_isns232c,@function
_iocs_isns232c:
	moveq	#0x33, %d0
	trap	#15
	rts
