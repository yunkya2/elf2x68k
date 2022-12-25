| int _iocs_sp_reggt (int, int *, int *, int *, int *);
.text
.even
.global _iocs_sp_reggt
.type _iocs_sp_reggt,@function
_iocs_sp_reggt:
	movem.l	%d2/%d3/%d4/%d5, %sp@-
	move.l	%sp@(20), %d1
	moveq	#0xffffffc7, %d0
	trap	#15
	tst.l	%d0
	bnes	6f
	movem.l	%sp@(24), %a0/%a1
	move.l	%d2, %a0@
	move.l	%d3, %a1@
	movem.l	%sp@(32), %a0/%a1
	move.l	%d4, %a0@
	move.l	%d5, %a1@
6:
	movem.l	%sp@+,%d2/%d3/%d4/%d5
	rts
