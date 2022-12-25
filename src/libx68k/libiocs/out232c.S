| void _iocs_out232c (int);
.text
.even
.global _iocs_out232c
.type _iocs_out232c,@function
_iocs_out232c:
	move.l	%sp@(4), %d1
	moveq	#0x35, %d0
	trap	#15
	rts
