| int _iocs_sp_regst (int, int, int, int, int, int);
.text
.even
.global _iocs_sp_regst
.type _iocs_sp_regst,@function
_iocs_sp_regst:
	movem.l	%d2/%d3/%d4/%d5, %sp@-
	movem.l	%sp@(20),%d0/%d1/%d2/%d3/%d4/%d5
	and.l	#0x80000000, %d1
	move.b	%d0, %d1
	moveq	#0xffffffc6, %d0
	trap	#15
	movem.l	%sp@+,%d2/%d3/%d4/%d5
	rts
