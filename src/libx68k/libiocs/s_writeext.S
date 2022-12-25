| int _iocs_s_writeext (int, int, int, int, void *);
.text
.even
.global _iocs_s_writeext
.type _iocs_s_writeext,@function
_iocs_s_writeext:
	movem.l	%d2/%d3/%d4/%d5, %sp@-
	movem.l	%sp@(20),%d2/%d3/%d4/%d5/%a1
	moveq	#39, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	movem.l	%sp@+,%d2/%d3/%d4/%d5
	rts
