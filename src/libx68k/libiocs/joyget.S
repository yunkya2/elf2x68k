| int _iocs_joyget (int);
.text
.even
.global _iocs_joyget
.type _iocs_joyget,@function
_iocs_joyget:
	move.l	%sp@(4), %d1
	moveq	#0x3b, %d0
	trap	#15
	rts
