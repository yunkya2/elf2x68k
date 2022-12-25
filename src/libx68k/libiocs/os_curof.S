| void _iocs_os_curof (void);
.text
.even
.global _iocs_os_curof
.type _iocs_os_curof,@function
_iocs_os_curof:
	moveq	#0xffffffaf, %d0
	trap	#15
	rts
