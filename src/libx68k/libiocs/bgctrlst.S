| int _iocs_bgctrlst (int, int, int);
.text
.even
.global _iocs_bgctrlst
.type _iocs_bgctrlst,@function
_iocs_bgctrlst:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0xffffffca, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
