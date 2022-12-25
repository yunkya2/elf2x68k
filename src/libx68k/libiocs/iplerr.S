| __dead void _iocs_iplerr (void);
.text
.even
.global _iocs_iplerr
.type _iocs_iplerr,@function
_iocs_iplerr:
	moveq	#0xfffffffe, %d0
	trap	#15
