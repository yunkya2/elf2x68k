| void _iocs_ms_patst (int, const struct _iocs_patst *);
.text
.even
.global _iocs_ms_patst
.type _iocs_ms_patst,@function
_iocs_ms_patst:
	movem.l	%sp@(4),%d1/%a1
	moveq	#0x7a, %d0
	trap	#15
	rts
