| void _iocs_txrascpy (int, int, int);
.text
.even
.global _iocs_txrascpy
.type _iocs_txrascpy,@function
_iocs_txrascpy:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0xffffffdf, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
