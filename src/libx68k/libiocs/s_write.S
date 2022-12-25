| int _iocs_s_write (int, int, int, int, void *);
.text
.even
.global _iocs_s_write
.type _iocs_s_write,@function
_iocs_s_write:
	movem.l	%d2/%d3/%d4/%d5, %sp@-
	movem.l	%sp@(20),%d2/%d3/%d4/%d5/%a1
	moveq	#34, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	movem.l	%sp@+,%d2/%d3/%d4/%d5
	rts
