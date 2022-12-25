| int _iocs_bgtextgt (int, int, int);
.text
.even
.global _iocs_bgtextgt
.type _iocs_bgtextgt,@function
_iocs_bgtextgt:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0xffffffce, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
