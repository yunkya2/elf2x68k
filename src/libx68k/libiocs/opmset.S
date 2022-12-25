| void _iocs_opmset (int, int);
.text
.even
.global _iocs_opmset
.type _iocs_opmset,@function
_iocs_opmset:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x68, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
