| int _iocs_b_seek (int, int);
.text
.even
.global _iocs_b_seek
.type _iocs_b_seek,@function
_iocs_b_seek:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x40, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
