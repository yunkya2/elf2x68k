| int _iocs_b_readdi (int, int, int, void *);
.text
.even
.global _iocs_b_readdi
.type _iocs_b_readdi,@function
_iocs_b_readdi:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3/%a1
	moveq	#0x42, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
