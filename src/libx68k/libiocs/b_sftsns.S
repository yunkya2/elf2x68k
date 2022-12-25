| int _iocs_b_sftsns (void);
.text
.even
.global _iocs_b_sftsns
.type _iocs_b_sftsns,@function
_iocs_b_sftsns:
	moveq	#0x02, %d0
	trap	#15
	rts
