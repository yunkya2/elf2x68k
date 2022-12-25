| int _iocs_b_keysns (void);
.text
.even
.global _iocs_b_keysns
.type _iocs_b_keysns,@function
_iocs_b_keysns:
	moveq	#0x01, %d0
	trap	#15
	rts
