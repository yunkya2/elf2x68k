| int _iocs_timebin (int);
.text
.even
.global _iocs_timebin
.type _iocs_timebin,@function
_iocs_timebin:
	move.l	%sp@(4), %d1
	moveq	#0x57, %d0
	trap	#15
	rts
