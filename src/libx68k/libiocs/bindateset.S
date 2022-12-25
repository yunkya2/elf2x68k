| void _iocs_bindateset (int);
.text
.even
.global _iocs_bindateset
.type _iocs_bindateset,@function
_iocs_bindateset:
	move.l	%sp@(4), %d1
	moveq	#0x51, %d0
	trap	#15
	rts
