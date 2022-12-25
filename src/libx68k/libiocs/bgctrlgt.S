| int _iocs_bgctrlgt (int);
.text
.even
.global _iocs_bgctrlgt
.type _iocs_bgctrlgt,@function
_iocs_bgctrlgt:
	move.l	%sp@(4), %d1
	moveq	#0xffffffcb, %d0
	trap	#15
	rts
