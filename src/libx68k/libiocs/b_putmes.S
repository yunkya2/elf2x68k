| int _iocs_b_putmes (int, int, int, int, const char *);
.text
.even
.global _iocs_b_putmes
.type _iocs_b_putmes,@function
_iocs_b_putmes:
	movem.l	%d2/%d3/%d4, %sp@-
	movem.l	%sp@(16),%d1/%d2/%d3/%d4/%a1
	moveq	#0x2f, %d0
	trap	#15
	move.l	%d2, %d0
	movem.l	%sp@+,%d2/%d3/%d4
	rts
