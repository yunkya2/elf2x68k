| void _iocs_tvctrl (int);
.text
.even
.global _iocs_tvctrl
.type _iocs_tvctrl,@function
_iocs_tvctrl:
	move.l	%sp@(4), %d1
	moveq	#0x0c, %d0
	trap	#15
	rts
