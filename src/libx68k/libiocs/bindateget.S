| int _iocs_bindateget (void);
.text
.even
.global _iocs_bindateget
.type _iocs_bindateget,@function
_iocs_bindateget:
	moveq	#0x54, %d0
	trap	#15
	rts
