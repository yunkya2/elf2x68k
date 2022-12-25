| void _iocs_ledmod (int, int);
.text
.even
.global _iocs_ledmod
.type _iocs_ledmod,@function
_iocs_ledmod:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x0d, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
