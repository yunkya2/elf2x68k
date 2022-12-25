| int _iocs_alarmmod (int);
.text
.even
.global _iocs_alarmmod
.type _iocs_alarmmod,@function
_iocs_alarmmod:
	move.l	%sp@(4), %d1
	moveq	#0x5d, %d0
	trap	#15
	rts
