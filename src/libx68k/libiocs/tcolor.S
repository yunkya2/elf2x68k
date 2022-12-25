| void _iocs_tcolor (int);
.text
.even
.global _iocs_tcolor
.type _iocs_tcolor,@function
_iocs_tcolor:
	move.l	%sp@(4), %d1
	moveq	#0x15, %d0
	trap	#15
	rts
