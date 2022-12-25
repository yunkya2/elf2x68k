| void _iocs_txxline (const struct _iocs_xlineptr *);
.text
.even
.global _iocs_txxline
.type _iocs_txxline,@function
_iocs_txxline:
	move.l	%sp@(4), %a1
	moveq	#0xffffffd3, %d0
	trap	#15
	rts
