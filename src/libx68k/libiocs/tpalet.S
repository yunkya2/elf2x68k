| int _iocs_tpalet (int, int);
.text
.even
.global _iocs_tpalet
.type _iocs_tpalet,@function
_iocs_tpalet:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x13, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
