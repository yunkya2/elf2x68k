| void _iocs_abortrst (void);
.text
.even
.global _iocs_abortrst
.type _iocs_abortrst,@function
_iocs_abortrst:
	moveq	#0xfffffffd, %d0
	trap	#15
	rts
