| int _iocs_ms_ontm (int, int);
.text
.even
.global _iocs_ms_ontm
.type _iocs_ms_ontm,@function
_iocs_ms_ontm:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x79, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
