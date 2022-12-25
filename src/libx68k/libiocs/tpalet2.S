| int _iocs_tpalet2 (int, int);
.text
.even
.global _iocs_tpalet2
.type _iocs_tpalet2,@function
_iocs_tpalet2:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x14, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
