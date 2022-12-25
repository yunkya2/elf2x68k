| void _iocs_ms_sel2 (const short *);
.text
.even
.global _iocs_ms_sel2
.type _iocs_ms_sel2,@function
_iocs_ms_sel2:
	move.l	%sp@(4), %a1
	moveq	#0x7c, %d0
	trap	#15
	rts
