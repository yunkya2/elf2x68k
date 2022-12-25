| int _iocs_bgtextst (int, int, int, int);
.text
.even
.global _iocs_bgtextst
.type _iocs_bgtextst,@function
_iocs_bgtextst:
	movem.l	%d2/%d3/%d4, %sp@-
	movem.l	%sp@(16),%d1/%d2/%d3/%d4
	moveq	#0xffffffcd, %d0
	trap	#15
	movem.l	%sp@+,%d2/%d3/%d4
	rts
