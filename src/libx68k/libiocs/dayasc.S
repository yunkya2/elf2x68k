| void _iocs_dayasc (int, char *);
.text
.even
.global _iocs_dayasc
.type _iocs_dayasc,@function
_iocs_dayasc:
	movem.l	%sp@(4),%d1/%a1
	moveq	#0x5c, %d0
	trap	#15
	rts
