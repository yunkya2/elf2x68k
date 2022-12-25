| void _iocs_txline (struct _iocs_tlineptr); /* 1.3, iocs.x */
.text
.even
.global _iocs_txline
.type _iocs_txline,@function
_iocs_txline:
	move.l	%sp@(4), %a1
	moveq	#0xffffffd5, %d0
	trap	#15
	rts
