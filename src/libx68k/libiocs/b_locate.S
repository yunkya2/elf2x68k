| int _iocs_b_locate (int, int);
.text
.even
.global _iocs_b_locate
.type _iocs_b_locate,@function
_iocs_b_locate:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x23, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
