| void _iocs_outprn (int);
.text
.even
.global _iocs_outprn
.type _iocs_outprn,@function
_iocs_outprn:
	move.l	%sp@(4), %d1
	moveq	#0x3f, %d0
	trap	#15
	rts
