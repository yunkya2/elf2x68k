| void _iocs_txfill (const struct _iocs_txfillptr *);
.text
.even
.global _iocs_txfill
.type _iocs_txfill,@function
_iocs_txfill:
	move.l	%sp@(4), %a1
	moveq	#0xffffffd7, %d0
	trap	#15
	rts
