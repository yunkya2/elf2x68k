| void _iocs_ms_sel (int);
.text
.even
.global _iocs_ms_sel
.type _iocs_ms_sel,@function
_iocs_ms_sel:
	move.l	%sp@(4), %d1
	moveq	#0x7b, %d0
	trap	#15
	rts
