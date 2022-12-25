| void _iocs_timeset (int);
.text
.even
.global _iocs_timeset
.type _iocs_timeset,@function
_iocs_timeset:
	move.l	%sp@(4), %d1
	moveq	#0x53, %d0
	trap	#15
	rts
