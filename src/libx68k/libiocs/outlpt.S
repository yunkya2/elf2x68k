| void _iocs_outlpt (int);
.text
.even
.global _iocs_outlpt
.type _iocs_outlpt,@function
_iocs_outlpt:
	move.l	%sp@(4), %d1
	moveq	#0x3e, %d0
	trap	#15
	rts
