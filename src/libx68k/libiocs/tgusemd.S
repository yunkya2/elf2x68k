| int _iocs_tgusemd (int, int);
.text
.even
.global _iocs_tgusemd
.type _iocs_tgusemd,@function
_iocs_tgusemd:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x0e, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
