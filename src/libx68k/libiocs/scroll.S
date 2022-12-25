| void _iocs_scroll (int, int, int);
.text
.even
.global _iocs_scroll
.type _iocs_scroll,@function
_iocs_scroll:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0x1d, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
