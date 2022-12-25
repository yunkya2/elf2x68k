| int _iocs_b_badfmt (int, int, int);
.text
.even
.global _iocs_b_badfmt
.type _iocs_b_badfmt,@function
_iocs_b_badfmt:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0x4b, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
