| int _iocs_snsprn (void);
.text
.even
.global _iocs_snsprn
.type _iocs_snsprn,@function
_iocs_snsprn:
	moveq	#0x3d, %d0
	trap	#15
	rts
