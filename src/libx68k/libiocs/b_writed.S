| int _iocs_b_writed (int, int, int, const void *);
.text
.even
.global _iocs_b_writed
.type _iocs_b_writed,@function
_iocs_b_writed:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3/%a1
	moveq	#0x49, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
