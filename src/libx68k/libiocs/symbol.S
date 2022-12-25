| int _iocs_symbol (const struct _iocs_symbolptr *);
.text
.even
.global _iocs_symbol
.type _iocs_symbol,@function
_iocs_symbol:
	move.l	%sp@(4), %a1
	moveq	#0xffffffbd, %d0
	trap	#15
	rts
