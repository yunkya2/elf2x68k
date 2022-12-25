| int _iocs_window (int, int, int, int);
.text
.even
.global _iocs_window
.type _iocs_window,@function
_iocs_window:
	movem.l	%d2/%d3/%d4, %sp@-
	movem.l	%sp@(16),%d1/%d2/%d3/%d4
	moveq	#0xffffffb4, %d0
	trap	#15
	movem.l	%sp@+,%d2/%d3/%d4
	rts
