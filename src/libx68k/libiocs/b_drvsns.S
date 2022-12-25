| int _iocs_b_drvsns (int);
.text
.even
.global _iocs_b_drvsns
.type _iocs_b_drvsns,@function
_iocs_b_drvsns:
	move.l	%sp@(4), %d1
	moveq	#0x44, %d0
	trap	#15
	rts
