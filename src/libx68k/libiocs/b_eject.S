| int _iocs_b_eject (int);
.text
.even
.global _iocs_b_eject
.type _iocs_b_eject,@function
_iocs_b_eject:
	move.l	%sp@(4), %d1
	moveq	#0x4f, %d0
	trap	#15
	rts
