| void _iocs_txrev (const struct _iocs_trevptr *);
.text
.even
.global _iocs_txrev
.type _iocs_txrev,@function
_iocs_txrev:
	move.l	%sp@(4), %a1
	moveq	#0xffffffd8, %d0
	trap	#15
	rts
