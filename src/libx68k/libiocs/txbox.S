| void _iocs_txbox (const struct _iocs_tboxptr *);
.text
.even
.global _iocs_txbox
.type _iocs_txbox,@function
_iocs_txbox:
	move.l	%sp@(4), %a1
	moveq	#0xffffffd6, %d0
	trap	#15
	rts
