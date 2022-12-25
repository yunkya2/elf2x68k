| int _iocs_opmsns (void);
.text
.even
.global _iocs_opmsns
.type _iocs_opmsns,@function
_iocs_opmsns:
	moveq	#0x69, %d0
	trap	#15
	rts
