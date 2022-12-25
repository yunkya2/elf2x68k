| int _iocs_alarmset (int, int, int);
.text
.even
.global _iocs_alarmset
.type _iocs_alarmset,@function
_iocs_alarmset:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2/%a1
	moveq	#0x5e, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
