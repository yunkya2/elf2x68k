| int _iocs_timebcd (int);
.text
.even
.global _iocs_timebcd
.type _iocs_timebcd,@function
_iocs_timebcd:
	move.l	%sp@(4), %d1
	moveq	#0x52, %d0
	trap	#15
	rts
