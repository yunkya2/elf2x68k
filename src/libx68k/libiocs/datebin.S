| int _iocs_datebin (int);
.text
.even
.global _iocs_datebin
.type _iocs_datebin,@function
_iocs_datebin:
	move.l	%sp@(4), %d1
	moveq	#0x55, %d0
	trap	#15
	rts
