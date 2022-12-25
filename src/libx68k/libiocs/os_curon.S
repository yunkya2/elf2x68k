| void _iocs_os_curon (void);
.text
.even
.global _iocs_os_curon
.type _iocs_os_curon,@function
_iocs_os_curon:
	moveq	#0xffffffae, %d0
	trap	#15
	rts
