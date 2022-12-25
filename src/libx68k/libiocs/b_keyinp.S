| int _iocs_b_keyinp (void);
.text
.even
.global _iocs_b_keyinp
.type _iocs_b_keyinp,@function
_iocs_b_keyinp:
	moveq	#0x00, %d0
	trap	#15
	rts
