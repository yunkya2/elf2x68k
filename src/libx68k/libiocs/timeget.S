| int _iocs_timeget (void);
.text
.even
.global _iocs_timeget
.type _iocs_timeget,@function
_iocs_timeget:
	moveq	#0x56, %d0
	trap	#15
	rts
