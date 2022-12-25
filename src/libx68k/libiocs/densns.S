| void _iocs_densns (void);
.text
.even
.global _iocs_densns
.type _iocs_densns,@function
_iocs_densns:
	moveq	#0x7e, %d0
	trap	#15
	rts
